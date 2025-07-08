#!/bin/bash

# Git Secret Scanning and Analysis Script
# This script provides comprehensive secret detection and analysis for Git repositories

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_PATH="${1:-$(pwd)}"
OUTPUT_DIR="./security_scan_results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo -e "${BLUE}🔍 Git Repository Secret Scanner${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install missing tools
install_missing_tools() {
    echo -e "${YELLOW}📦 Checking required tools...${NC}"
    
    if ! command_exists trufflehog; then
        echo -e "${RED}❌ TruffleHog not found. Please install it first:${NC}"
        echo "brew install trufflehog"
        exit 1
    fi
    
    if ! command_exists git-filter-repo; then
        echo -e "${YELLOW}⚠️  git-filter-repo not found. Installing...${NC}"
        if command_exists brew; then
            brew install git-filter-repo
        elif command_exists pip3; then
            pip3 install git-filter-repo
        else
            echo -e "${RED}❌ Please install git-filter-repo manually${NC}"
            echo "Visit: https://github.com/newren/git-filter-repo"
        fi
    fi
    
    echo -e "${GREEN}✅ Tool check complete${NC}"
    echo ""
}

# Function to run TruffleHog scan
run_trufflehog_scan() {
    echo -e "${BLUE}🔍 Running TruffleHog scan...${NC}"
    
    local scan_file="$OUTPUT_DIR/trufflehog_scan_$TIMESTAMP.json"
    local summary_file="$OUTPUT_DIR/scan_summary_$TIMESTAMP.txt"
    
    # Get the remote URL or use local path
    local git_url
    if git remote get-url origin >/dev/null 2>&1; then
        git_url=$(git remote get-url origin)
        echo "Scanning remote repository: $git_url"
    else
        echo "No remote found, scanning local repository"
        git_url="file://$(pwd)"
    fi
    
    # Run TruffleHog with different detectors
    echo "Running TruffleHog scan..."
    if trufflehog --json --regex "$git_url" > "$scan_file" 2>/dev/null; then
        echo -e "${GREEN}✅ TruffleHog scan completed${NC}"
    else
        echo -e "${YELLOW}⚠️  TruffleHog scan completed with warnings${NC}"
    fi
    
    # Process results
    if [ -s "$scan_file" ]; then
        echo -e "${RED}🚨 SECRETS FOUND!${NC}"
        
        # Create summary
        {
            echo "Secret Scan Summary - $(date)"
            echo "================================="
            echo ""
            
            echo "Files containing secrets:"
            jq -r '.path' "$scan_file" 2>/dev/null | sort | uniq -c | sort -nr || cat "$scan_file" | grep -o '"path":"[^"]*"' | cut -d'"' -f4 | sort | uniq -c | sort -nr
            
            echo ""
            echo "Types of secrets found:"
            jq -r '.reason' "$scan_file" 2>/dev/null | sort | uniq -c | sort -nr || cat "$scan_file" | grep -o '"reason":"[^"]*"' | cut -d'"' -f4 | sort | uniq -c | sort -nr
            
            echo ""
            echo "Commits containing secrets:"
            jq -r '.commitHash' "$scan_file" 2>/dev/null | sort | uniq || cat "$scan_file" | grep -o '"commitHash":"[^"]*"' | cut -d'"' -f4 | sort | uniq
            
        } > "$summary_file"
        
        cat "$summary_file"
        echo ""
        echo -e "${YELLOW}📄 Detailed results saved to: $scan_file${NC}"
        echo -e "${YELLOW}📊 Summary saved to: $summary_file${NC}"
        
        return 1
    else
        echo -e "${GREEN}✅ No secrets found in repository${NC}"
        return 0
    fi
}

# Function to analyze git history for sensitive patterns
analyze_git_history() {
    echo -e "${BLUE}📊 Analyzing Git history for sensitive patterns...${NC}"
    
    local history_file="$OUTPUT_DIR/git_history_analysis_$TIMESTAMP.txt"
    
    {
        echo "Git History Analysis - $(date)"
        echo "==============================="
        echo ""
        
        echo "Commits mentioning sensitive keywords:"
        git log --all --full-history --grep="password\|secret\|key\|token\|credential" --oneline
        
        echo ""
        echo "Files that have been deleted (potential secret cleanup attempts):"
        git log --all --full-history --diff-filter=D --summary | grep delete
        
        echo ""
        echo "Large files in history (potential binary secrets):"
        git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
        awk '/^blob/ {if($3 > 1048576) print $3, $4}' | sort -nr | head -10
        
    } > "$history_file"
    
    echo -e "${GREEN}✅ Git history analysis completed${NC}"
    echo -e "${YELLOW}📄 Results saved to: $history_file${NC}"
    echo ""
}

# Function to create cleanup script
create_cleanup_script() {
    echo -e "${BLUE}🧹 Creating cleanup script...${NC}"
    
    local cleanup_script="$OUTPUT_DIR/cleanup_secrets.sh"
    
    cat > "$cleanup_script" << 'EOF'
#!/bin/bash

# Git Secret Cleanup Script
# WARNING: This script will rewrite Git history and require force push!

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}⚠️  WARNING: This script will rewrite Git history!${NC}"
echo -e "${RED}⚠️  All team members will need to re-clone the repository!${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

# Create backup
echo -e "${YELLOW}📦 Creating backup...${NC}"
git clone . ../backup_$(date +%Y%m%d_%H%M%S) --bare

# Method 1: Remove specific files from history using git-filter-repo
echo -e "${BLUE}🧹 Removing sensitive files from history...${NC}"

# List of files to remove (add more as needed)
FILES_TO_REMOVE=(
    "keys"
    "new_key"
    "*.pem"
    "*.key"
    "*password*"
    "*secret*"
    "*.env"
    ".aws/credentials"
)

for file in "${FILES_TO_REMOVE[@]}"; do
    if git log --all --full-history -- "$file" | grep -q "commit"; then
        echo "Removing $file from history..."
        git filter-repo --path "$file" --invert-paths --force
    fi
done

# Method 2: Remove content based on patterns (alternative approach)
# Uncomment and modify as needed:
# echo -e "${BLUE}🧹 Removing sensitive content patterns...${NC}"
# git filter-repo --replace-text <(cat << 'PATTERNS'
# AKIA[0-9A-Z]{16}==>***REMOVED-AWS-KEY***
# [A-Za-z0-9/+=]{40}==>***REMOVED-SECRET***
# -----BEGIN[A-Z ]*PRIVATE KEY----==>***REMOVED-PRIVATE-KEY***
# https://[^:]+:[^@]+@==>https://***REMOVED-CREDENTIALS***@
# PATTERNS
# ) --force

echo -e "${GREEN}✅ Cleanup completed!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Verify the cleanup was successful"
echo "2. Force push to remote: git push --force-with-lease --all"
echo "3. Force push tags: git push --force-with-lease --tags"
echo "4. Notify all team members to re-clone the repository"
echo "5. Revoke and regenerate all exposed credentials"

EOF
    
    chmod +x "$cleanup_script"
    echo -e "${GREEN}✅ Cleanup script created: $cleanup_script${NC}"
    echo ""
}

# Function to create prevention setup script
create_prevention_script() {
    echo -e "${BLUE}🛡️  Creating prevention setup script...${NC}"
    
    local prevention_script="$OUTPUT_DIR/setup_prevention.sh"
    
    cat > "$prevention_script" << 'EOF'
#!/bin/bash

# Git Secret Prevention Setup Script

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🛡️  Setting up secret prevention measures...${NC}"
echo ""

# Install pre-commit if not present
if ! command -v pre-commit >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing pre-commit...${NC}"
    if command -v pip3 >/dev/null 2>&1; then
        pip3 install pre-commit
    elif command -v brew >/dev/null 2>&1; then
        brew install pre-commit
    else
        echo "Please install pre-commit manually: https://pre-commit.com/"
        exit 1
    fi
fi

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'PRECOMMIT_CONFIG'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-merge-conflict
      - id: check-added-large-files
      - id: detect-private-key
      - id: detect-aws-credentials

  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']

  - repo: https://github.com/trufflesecurity/trufflehog
    rev: v3.63.2
    hooks:
      - id: trufflehog
        name: TruffleHog
        description: Detect hardcoded secrets
        entry: bash -c 'trufflehog git file://. --since-commit HEAD --only-verified --fail'
        language: system
        stages: ["commit", "push"]
PRECOMMIT_CONFIG

# Initialize pre-commit baseline
echo -e "${YELLOW}Initializing secrets baseline...${NC}"
if command -v detect-secrets >/dev/null 2>&1; then
    detect-secrets scan --baseline .secrets.baseline
else
    echo "detect-secrets not found, installing..."
    pip3 install detect-secrets
    detect-secrets scan --baseline .secrets.baseline
fi

# Install pre-commit hooks
echo -e "${YELLOW}Installing pre-commit hooks...${NC}"
pre-commit install

# Create .gitignore for sensitive files
cat >> .gitignore << 'GITIGNORE'

# Security - Sensitive files
*.pem
*.key
*.p12
*.pfx
*.cer
*.crt
*.der
*.jks
*.keystore
*.env
.env.*
config/secrets.yml
config/database.yml
config/master.key
.aws/credentials
.ssh/id_*
secrets.txt
passwords.txt
GITIGNORE

# Create security documentation
cat > SECURITY.md << 'SECURITY_DOC'
# Security Guidelines

## Secrets Management

### What NOT to commit:
- API keys and tokens
- Passwords and credentials
- Private keys and certificates
- Database connection strings
- OAuth secrets
- Any configuration containing sensitive data

### Best Practices:
1. Use environment variables for secrets
2. Use secret management tools (AWS Secrets Manager, HashiCorp Vault)
3. Encrypt sensitive configuration files
4. Use .env files (and add them to .gitignore)
5. Regular secret rotation

### Tools in place:
- Pre-commit hooks with secret detection
- TruffleHog scanning
- Regular security audits

### If you accidentally commit a secret:
1. Immediately revoke/regenerate the credential
2. Contact the security team
3. Follow the secret cleanup procedure
4. Never assume deletion from the latest commit is sufficient

## Reporting Security Issues
Please report security vulnerabilities to: security@company.com
SECURITY_DOC

echo -e "${GREEN}✅ Prevention measures setup completed!${NC}"
echo ""
echo "Configured:"
echo "- Pre-commit hooks with secret detection"
echo "- TruffleHog integration"
echo "- Enhanced .gitignore"
echo "- Security documentation"
echo ""
echo "Next steps:"
echo "1. Test pre-commit hooks: pre-commit run --all-files"
echo "2. Train team on security practices"
echo "3. Set up CI/CD secret scanning"
echo "4. Implement secret management solution"

EOF
    
    chmod +x "$prevention_script"
    echo -e "${GREEN}✅ Prevention script created: $prevention_script${NC}"
    echo ""
}

# Function to generate comprehensive report
generate_report() {
    echo -e "${BLUE}📋 Generating comprehensive security report...${NC}"
    
    local report_file="$OUTPUT_DIR/security_report_$TIMESTAMP.md"
    
    cat > "$report_file" << EOF
# Git Repository Security Audit Report

**Generated:** $(date)  
**Repository:** $(git remote get-url origin 2>/dev/null || echo "Local repository")  
**Branch:** $(git branch --show-current)  
**Commit:** $(git rev-parse HEAD)  

## Executive Summary

This report details the security audit of the Git repository, including:
- Secret detection results
- Affected files and commits
- Remediation recommendations
- Prevention measures

## Scan Results

$(if [ -f "$OUTPUT_DIR/scan_summary_$TIMESTAMP.txt" ]; then cat "$OUTPUT_DIR/scan_summary_$TIMESTAMP.txt"; else echo "No secrets detected in scan."; fi)

## Risk Assessment

### High Risk Issues:
- Exposed AWS credentials (immediate revocation required)
- SSH private keys in commit history
- Basic authentication credentials

### Medium Risk Issues:
- Historical presence of secrets in deleted files
- Potential for additional undiscovered secrets

### Low Risk Issues:
- Repository lacks preventive measures

## Immediate Actions Required:

1. **🚨 URGENT: Revoke all exposed credentials**
2. **🧹 Clean commit history using provided cleanup script**
3. **🛡️  Implement prevention measures**
4. **👥 Team notification and re-cloning**

## Files Generated:

- \`cleanup_secrets.sh\` - Removes secrets from Git history
- \`setup_prevention.sh\` - Sets up future protection
- Detailed scan results in JSON format
- This comprehensive report

## Next Steps:

1. Review and execute cleanup script
2. Implement prevention measures
3. Train team on secure coding practices
4. Set up continuous security monitoring

---
*This report was generated automatically. Review all findings manually before taking action.*
EOF
    
    echo -e "${GREEN}✅ Security report generated: $report_file${NC}"
    echo ""
}

# Main execution
main() {
    echo "Starting security audit for repository: $REPO_PATH"
    echo ""
    
    cd "$REPO_PATH"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}❌ Not a Git repository!${NC}"
        exit 1
    fi
    
    install_missing_tools
    
    local secrets_found=false
    if ! run_trufflehog_scan; then
        secrets_found=true
    fi
    
    analyze_git_history
    create_cleanup_script
    create_prevention_script
    generate_report
    
    echo -e "${BLUE}🎯 Security Audit Complete!${NC}"
    echo -e "${BLUE}=========================${NC}"
    echo ""
    
    if [ "$secrets_found" = true ]; then
        echo -e "${RED}🚨 SECRETS DETECTED!${NC}"
        echo -e "${YELLOW}📁 Check results in: $OUTPUT_DIR${NC}"
        echo ""
        echo -e "${YELLOW}⚡ Quick start:${NC}"
        echo "1. Review scan results"
        echo "2. Run: $OUTPUT_DIR/cleanup_secrets.sh"
        echo "3. Run: $OUTPUT_DIR/setup_prevention.sh"
    else
        echo -e "${GREEN}✅ No secrets found!${NC}"
        echo -e "${YELLOW}💡 Still recommended to run prevention setup:${NC}"
        echo "   $OUTPUT_DIR/setup_prevention.sh"
    fi
    
    echo ""
    echo -e "${BLUE}📚 Documentation: secret_remediation_guide.md${NC}"
}

# Run main function
main "$@"
