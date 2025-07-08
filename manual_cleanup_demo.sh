#!/bin/bash

# Manual Secret Cleanup Script for Current Repository
# This script demonstrates the cleanup process for the identified secrets

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}⚠️  CRITICAL: Manual Secret Cleanup for Test Repository${NC}"
echo -e "${RED}================================================${NC}"
echo ""

# First, let's see what we're working with
echo -e "${BLUE}📊 Current repository status:${NC}"
echo "Repository: $(pwd)"
echo "Current branch: $(git branch --show-current)"
echo "Latest commit: $(git log -1 --oneline)"
echo ""

# Show the current secrets in files
echo -e "${BLUE}🔍 Current secrets in working directory:${NC}"
echo ""
echo "=== Contents of 'keys' file ==="
if [ -f "keys" ]; then
    cat keys
else
    echo "File 'keys' not found"
fi

echo ""
echo "=== Contents of 'new_key' file ==="
if [ -f "new_key" ]; then
    cat new_key
else
    echo "File 'new_key' not found"
fi

echo ""
echo -e "${YELLOW}🎯 Secrets identified by TruffleHog:${NC}"
echo "1. AWS Access Key: AKIAQYLPMN5HHHFPZAM2"
echo "2. AWS Secret Key: 1tUm636uS1yOEcfP5pvfqJ/ml36mF7AkyHsEU0IUi"
echo "3. AWS Access Key: AKIAYVP4CIPPERUVIFXG"
echo "4. AWS Secret Key: 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"
echo "5. OpenSSH Private Key (full key in 'keys' file)"
echo "6. Basic Auth: https://admin:admin@the-internet.herokuapp.com/basic_auth"
echo ""

echo -e "${YELLOW}📋 Affected commits:${NC}"
git log --oneline | head -10
echo ""

echo -e "${RED}⚠️  IMPORTANT NOTES:${NC}"
echo "1. These are TEST credentials from TruffleHog's demo repository"
echo "2. In a real scenario, you would:"
echo "   - Immediately revoke all exposed credentials"
echo "   - Rotate keys and passwords"
echo "   - Notify security team"
echo "   - Check for unauthorized access"
echo ""

read -p "Would you like to see the cleanup options? (y/n): " show_cleanup

if [ "$show_cleanup" = "y" ] || [ "$show_cleanup" = "Y" ]; then
    echo ""
    echo -e "${BLUE}🧹 Cleanup Options:${NC}"
    echo ""
    
    echo -e "${YELLOW}Option 1: Remove files from current commit only (NOT RECOMMENDED)${NC}"
    echo "git rm keys new_key"
    echo "git commit -m 'Remove sensitive files'"
    echo "⚠️  This leaves secrets in history!"
    echo ""
    
    echo -e "${YELLOW}Option 2: Remove files from entire history (RECOMMENDED)${NC}"
    echo "# Using git-filter-repo (install first: brew install git-filter-repo)"
    echo "git filter-repo --path keys --invert-paths --force"
    echo "git filter-repo --path new_key --invert-paths --force"
    echo ""
    
    echo -e "${YELLOW}Option 3: Replace sensitive content in history${NC}"
    echo "# Create a replacements file"
    echo "cat > replacements.txt << 'EOF'"
    echo "AKIAQYLPMN5HHHFPZAM2==>***REMOVED-AWS-KEY***"
    echo "1tUm636uS1yOEcfP5pvfqJ/ml36mF7AkyHsEU0IUi==>***REMOVED-SECRET***"
    echo "AKIAYVP4CIPPERUVIFXG==>***REMOVED-AWS-KEY***"
    echo "Zt2U1h267eViPnuSA+JO5ABhiu4T7XUMSZ+Y2Oth==>***REMOVED-SECRET***"
    echo "-----BEGIN OPENSSH PRIVATE KEY-----==>***REMOVED-PRIVATE-KEY***"
    echo "admin:admin@the-internet.herokuapp.com==>***REMOVED-CREDENTIALS***"
    echo "EOF"
    echo ""
    echo "git filter-repo --replace-text replacements.txt --force"
    echo ""
    
    echo -e "${BLUE}🔄 After cleanup, you would need to:${NC}"
    echo "1. Force push to remote: git push --force-with-lease --all"
    echo "2. Force push tags: git push --force-with-lease --tags"
    echo "3. Notify team members to re-clone"
    echo "4. Verify cleanup worked: re-run TruffleHog scan"
    echo ""
fi

echo -e "${GREEN}✅ For this demo repository, you can:${NC}"
echo "1. Run the comprehensive scanner: ./git_security_scanner.sh"
echo "2. Review the generated cleanup scripts"
echo "3. Practice the cleanup process in a safe environment"
echo ""

echo -e "${BLUE}📚 Remember: Prevention is better than cleanup!${NC}"
echo "- Set up pre-commit hooks"
echo "- Use environment variables for secrets"
echo "- Implement secret management tools"
echo "- Regular security training"
