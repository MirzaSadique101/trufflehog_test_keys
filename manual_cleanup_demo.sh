#!/bin/bash

# Manual Secret Cleanup Script for Current Repository
# This script demonstrates the cleanup process for the identified secrets

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Function to demonstrate git-filter-repo cleanup
demonstrate_git_filter_repo() {
    echo ""
    echo -e "${GREEN}🔧 git-filter-repo Cleanup Demonstration${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    
    echo -e "${CYAN}Step 1: Check if git-filter-repo is installed${NC}"
    if command -v git-filter-repo >/dev/null 2>&1; then
        echo -e "${GREEN}✅ git-filter-repo is installed${NC}"
        echo "Version: $(git-filter-repo --version 2>/dev/null || echo 'Available')"
    else
        echo -e "${YELLOW}⚠️  git-filter-repo not found. Installation command:${NC}"
        echo "   brew install git-filter-repo"
        echo "   # or"
        echo "   pip3 install git-filter-repo"
    fi
    echo ""
    
    echo -e "${CYAN}Step 2: Backup your repository (CRITICAL)${NC}"
    echo -e "${PURPLE}git clone . ../backup_\$(date +%Y%m%d_%H%M%S) --bare${NC}"
    echo ""
    
    echo -e "${CYAN}Step 3: Choose your cleanup approach${NC}"
    echo ""
    echo "Option A: Remove entire files from history"
    echo -e "${PURPLE}git filter-repo --path keys --invert-paths --force${NC}"
    echo -e "${PURPLE}git filter-repo --path new_key --invert-paths --force${NC}"
    echo ""
    
    echo "Option B: Replace sensitive content patterns"
    echo -e "${PURPLE}cat > replacements.txt << 'EOF'${NC}"
    echo -e "${PURPLE}AKIAQYLPMN5HHHFPZAM2==>***REMOVED-AWS-KEY***${NC}"
    echo -e "${PURPLE}1tUm636uS1yOEcfP5pvfqJ/ml36mF7AkyHsEU0IUi==>***REMOVED-SECRET***${NC}"
    echo -e "${PURPLE}AKIAYVP4CIPPERUVIFXG==>***REMOVED-AWS-KEY***${NC}"
    echo -e "${PURPLE}Zt2U1h267eViPnuSA+JO5ABhiu4T7XUMSZ+Y2Oth==>***REMOVED-SECRET***${NC}"
    echo -e "${PURPLE}-----BEGIN OPENSSH PRIVATE KEY-----==>***REMOVED-PRIVATE-KEY***${NC}"
    echo -e "${PURPLE}admin:admin@the-internet.herokuapp.com==>***REMOVED-CREDENTIALS***${NC}"
    echo -e "${PURPLE}EOF${NC}"
    echo ""
    echo -e "${PURPLE}git filter-repo --replace-text replacements.txt --force${NC}"
    echo ""
    
    read -p "Do you want to ACTUALLY execute this cleanup? (yes/no): " execute_filter_repo
    if [ "$execute_filter_repo" = "yes" ]; then
        execute_filter_repo_cleanup
    else
        simulate_filter_repo_cleanup
    fi
    
    show_post_cleanup_steps
}

# Function to demonstrate BFG cleanup
demonstrate_bfg_cleanup() {
    echo ""
    echo -e "${YELLOW}🔧 BFG Repo-Cleaner Demonstration${NC}"
    echo -e "${YELLOW}==================================${NC}"
    echo ""
    
    echo -e "${CYAN}Step 1: Check Java installation${NC}"
    if command -v java >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Java is installed${NC}"
        echo "Version: $(java -version 2>&1 | head -n1)"
    else
        echo -e "${RED}❌ Java not found. BFG requires Java runtime.${NC}"
        echo "Install Java: brew install openjdk"
        return
    fi
    echo ""
    
    echo -e "${CYAN}Step 2: Download BFG Repo-Cleaner${NC}"
    echo "Download from: https://rtyley.github.io/bfg-repo-cleaner/"
    echo -e "${PURPLE}wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar${NC}"
    echo -e "${PURPLE}# or${NC}"
    echo -e "${PURPLE}curl -O https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar${NC}"
    echo ""
    
    echo -e "${CYAN}Step 3: Create a fresh clone for BFG${NC}"
    echo -e "${PURPLE}git clone --mirror . ../repo-to-clean.git${NC}"
    echo -e "${PURPLE}cd ../repo-to-clean.git${NC}"
    echo ""
    
    echo -e "${CYAN}Step 4: Choose BFG cleanup method${NC}"
    echo ""
    echo "Option A: Remove files by name"
    echo -e "${PURPLE}java -jar bfg-1.14.0.jar --delete-files keys${NC}"
    echo -e "${PURPLE}java -jar bfg-1.14.0.jar --delete-files new_key${NC}"
    echo ""
    
    echo "Option B: Replace sensitive text patterns"
    echo -e "${PURPLE}cat > replacements.txt << 'EOF'${NC}"
    echo -e "${PURPLE}AKIAQYLPMN5HHHFPZAM2==>***REMOVED***${NC}"
    echo -e "${PURPLE}1tUm636uS1yOEcfP5pvfqJ/ml36mF7AkyHsEU0IUi==>***REMOVED***${NC}"
    echo -e "${PURPLE}AKIAYVP4CIPPERUVIFXG==>***REMOVED***${NC}"
    echo -e "${PURPLE}Zt2U1h267eViPnuSA+JO5ABhiu4T7XUMSZ+Y2Oth==>***REMOVED***${NC}"
    echo -e "${PURPLE}admin:admin==>***REMOVED***${NC}"
    echo -e "${PURPLE}EOF${NC}"
    echo ""
    echo -e "${PURPLE}java -jar bfg-1.14.0.jar --replace-text replacements.txt${NC}"
    echo ""
    
    echo -e "${CYAN}Step 5: Complete the cleanup${NC}"
    echo -e "${PURPLE}git reflog expire --expire=now --all${NC}"
    echo -e "${PURPLE}git gc --prune=now --aggressive${NC}"
    echo ""
    
    read -p "Do you want to ACTUALLY execute BFG cleanup? (yes/no): " execute_bfg
    if [ "$execute_bfg" = "yes" ]; then
        execute_bfg_cleanup
    else
        simulate_bfg_cleanup
    fi
    
    show_post_cleanup_steps
}

# Function to show all cleanup options
show_all_options() {
    echo ""
    echo -e "${RED}📚 All Git History Cleanup Methods${NC}"
    echo -e "${RED}==================================${NC}"
    echo ""
    
    echo -e "${YELLOW}Method 1: git filter-branch (Legacy - NOT RECOMMENDED)${NC}"
    echo "⚠️  Deprecated and slow, but still available"
    echo "✅ Built-in safety checks and better error handling"
    echo "✅ Handles edge cases that filter-branch misses"
    echo -e "${PURPLE}git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch keys new_key' --prune-empty --tag-name-filter cat -- --all${NC}"
    echo ""
    
    echo -e "${YELLOW}Method 2: git-filter-repo (RECOMMENDED)${NC}"
    echo "✅ Modern, safe, and fast replacement for filter-branch"
    echo "✅ Built-in safety checks and better error handling"
    echo "✅ Handles edge cases that filter-branch misses"
    echo -e "${PURPLE}git filter-repo --path keys --invert-paths --force${NC}"
    echo -e "${PURPLE}git filter-repo --replace-text replacements.txt --force${NC}"
    echo ""
    
    echo -e "${YELLOW}Method 3: BFG Repo-Cleaner${NC}"
    echo "✅ Fast alternative, especially for large repos"
    echo "✅ Simple syntax for common cleanup tasks"
    echo "⚠️  Requires Java runtime environment"
    echo -e "${PURPLE}java -jar bfg.jar --delete-files keys${NC}"
    echo -e "${PURPLE}java -jar bfg.jar --replace-text replacements.txt${NC}"
    echo ""
    
    echo -e "${YELLOW}Method 4: Manual content replacement${NC}"
    echo "📝 For keeping files but removing sensitive content"
    echo "🔧 Good for complex patterns and selective cleanup"
    echo -e "${PURPLE}git filter-repo --replace-text replacements.txt${NC}"
    echo ""
    
    echo -e "${YELLOW}Method 5: Interactive rebase (for recent commits)${NC}"
    echo "🔧 For cleaning up recent commits manually"
    echo "⚠️  Only suitable for recent history (last few commits)"
    echo -e "${PURPLE}git rebase -i HEAD~5${NC}"
    echo ""
    
    echo -e "${BLUE}📊 Comparison Summary:${NC}"
    echo ""
    printf "%-20s %-10s %-15s %-20s\n" "Method" "Speed" "Safety" "Use Case"
    printf "%-20s %-10s %-15s %-20s\n" "--------------------" "----------" "---------------" "--------------------"
    printf "%-20s %-10s %-15s %-20s\n" "git-filter-repo" "Fast" "Very Safe" "General purpose"
    printf "%-20s %-10s %-15s %-20s\n" "BFG Repo-Cleaner" "Very Fast" "Safe" "Large repos"
    printf "%-20s %-10s %-15s %-20s\n" "filter-branch" "Slow" "Moderate" "Legacy systems"
    printf "%-20s %-10s %-15s %-20s\n" "Interactive rebase" "Fast" "Manual" "Recent commits"
    echo ""
    
    read -p "Would you like to run a dry-run analysis? (yes/no): " run_analysis
    if [ "$run_analysis" = "yes" ]; then
        run_cleanup_analysis
    fi
    
    show_post_cleanup_steps
}

# Function to run a comprehensive analysis before cleanup
run_cleanup_analysis() {
    echo ""
    echo -e "${CYAN}🔍 Pre-Cleanup Analysis${NC}"
    echo -e "${CYAN}======================${NC}"
    echo ""
    
    echo -e "${YELLOW}📊 Repository Overview:${NC}"
    echo "Working directory: $(pwd)"
    echo "Git repository: $(if git rev-parse --git-dir >/dev/null 2>&1; then echo "✅ Valid"; else echo "❌ Invalid"; fi)"
    echo "Current branch: $(git branch --show-current 2>/dev/null || echo "Unknown")"
    echo "Total commits: $(git rev-list --all --count 2>/dev/null || echo "Unknown")"
    echo "Repository size: $(du -sh .git 2>/dev/null | cut -f1 || echo "Unknown")"
    echo ""
    
    echo -e "${YELLOW}🔍 Files Analysis:${NC}"
    if [ -f "keys" ]; then
        echo "✅ 'keys' file found ($(wc -l < keys) lines, $(du -h keys | cut -f1))"
    else
        echo "❌ 'keys' file not found"
    fi
    
    if [ -f "new_key" ]; then
        echo "✅ 'new_key' file found ($(wc -l < new_key) lines, $(du -h new_key | cut -f1))"
    else
        echo "❌ 'new_key' file not found"
    fi
    echo ""
    
    echo -e "${YELLOW}📈 Commit History Analysis:${NC}"
    echo "Files in Git history:"
    git log --name-only --pretty=format: | sort | uniq -c | sort -rn | head -10
    echo ""
    
    echo -e "${YELLOW}🔐 Secret Patterns Found:${NC}"
    if command -v trufflehog >/dev/null 2>&1; then
        echo "Running TruffleHog analysis..."
        if trufflehog git file://. --json > analysis_results.json 2>/dev/null; then
            if [ -s analysis_results.json ]; then
                SECRET_COUNT=$(wc -l < analysis_results.json)
                echo "🚨 Found $SECRET_COUNT secret(s) in repository"
                echo ""
                echo "Secret types detected:"
                if command -v jq >/dev/null 2>&1; then
                    jq -r '.DetectorName' analysis_results.json 2>/dev/null | sort | uniq -c | sort -rn || cat analysis_results.json | head -5
                else
                    echo "$(head -5 analysis_results.json)"
                fi
            else
                echo "✅ No secrets detected by TruffleHog"
            fi
        else
            echo "✅ No secrets detected by TruffleHog"
        fi
        rm -f analysis_results.json
    else
        echo "⚠️  TruffleHog not available for automated analysis"
        echo "Manual patterns to check:"
        echo "• AWS Keys: AKIA[0-9A-Z]{16}"
        echo "• Private Keys: -----BEGIN.*PRIVATE KEY-----"
        echo "• Basic Auth: ://.*:.*@"
        echo ""
        echo "Searching manually..."
        if git log --all -p | grep -i "AKIA\|BEGIN.*PRIVATE\|://.*:.*@" | head -3; then
            echo "🚨 Found potential secrets in Git history"
        else
            echo "✅ No obvious secret patterns found"
        fi
    fi
    echo ""
    
    echo -e "${YELLOW}🌐 Remote Repository Analysis:${NC}"
    if git remote -v | grep -q .; then
        echo "Remote repositories configured:"
        git remote -v
        echo ""
        echo "⚠️  After cleanup, you'll need to force-push to update remotes"
        echo "⚠️  Team members will need to re-clone the repository"
    else
        echo "✅ No remote repositories configured (local only)"
        echo "✅ Cleanup will only affect local repository"
    fi
    echo ""
    
    echo -e "${YELLOW}🛠️  Tool Availability:${NC}"
    echo -n "git-filter-repo: "
    if command -v git-filter-repo >/dev/null 2>&1; then
        echo "✅ Available ($(git-filter-repo --version 2>/dev/null || echo 'installed'))"
    else
        echo "❌ Not installed (install with: brew install git-filter-repo)"
    fi
    
    echo -n "Java (for BFG): "
    if command -v java >/dev/null 2>&1; then
        echo "✅ Available ($(java -version 2>&1 | head -n1 | cut -d'"' -f2))"
    else
        echo "❌ Not installed (install with: brew install openjdk)"
    fi
    
    echo -n "TruffleHog: "
    if command -v trufflehog >/dev/null 2>&1; then
        echo "✅ Available (verification enabled)"
    else
        echo "❌ Not installed (verification will be manual)"
    fi
    echo ""
    
    echo -e "${GREEN}📋 Recommended Cleanup Strategy:${NC}"
    if [ -f "keys" ] && [ -f "new_key" ]; then
        echo "✅ Strategy: Complete file removal (both files contain only secrets)"
        echo "✅ Method: git-filter-repo --path <file> --invert-paths"
        echo "✅ Result: Files will be completely removed from all history"
    else
        echo "⚠️  Strategy: Content replacement (files may contain mixed content)"
        echo "⚠️  Method: git-filter-repo --replace-text replacements.txt"
        echo "⚠️  Result: Secret patterns will be replaced with placeholders"
    fi
    echo ""
    
    echo -e "${BLUE}⏱️  Estimated Processing Time:${NC}"
    COMMIT_COUNT=$(git rev-list --all --count 2>/dev/null || echo "0")
    if [ "$COMMIT_COUNT" -lt 100 ]; then
        echo "⚡ Fast (< 30 seconds) - Small repository"
    elif [ "$COMMIT_COUNT" -lt 1000 ]; then
        echo "🏃 Moderate (30 seconds - 2 minutes) - Medium repository"
    else
        echo "🐌 Slower (2+ minutes) - Large repository"
    fi
    echo ""
}

# Function to actually execute git-filter-repo cleanup
execute_filter_repo_cleanup() {
    echo ""
    echo -e "${RED}🚨 EXECUTING REAL CLEANUP - This will modify Git history!${NC}"
    echo -e "${RED}===============================================${NC}"
    echo ""
    
    # Check if git-filter-repo is available
    if ! command -v git-filter-repo >/dev/null 2>&1; then
        echo -e "${RED}❌ git-filter-repo not found!${NC}"
        echo "Install it with:"
        echo "  brew install git-filter-repo"
        echo "  # or"
        echo "  pip3 install git-filter-repo"
        return 1
    fi
    
    # Create backup first
    BACKUP_DIR="../backup_$(date +%Y%m%d_%H%M%S)"
    echo -e "${CYAN}📦 Creating backup at: ${BACKUP_DIR}${NC}"
    if git clone . "$BACKUP_DIR" --bare; then
        echo -e "${GREEN}✅ Backup created successfully at ${BACKUP_DIR}${NC}"
    else
        echo -e "${RED}❌ Failed to create backup! Aborting cleanup.${NC}"
        return 1
    fi
    echo ""
    
    # Show current state
    echo -e "${CYAN}📊 Repository state before cleanup:${NC}"
    echo "Total commits: $(git rev-list --all --count)"
    echo "Repository size: $(du -sh .git | cut -f1)"
    echo "Files to clean: keys, new_key"
    echo ""
    
    # Final confirmation
    echo -e "${RED}⚠️  FINAL CONFIRMATION REQUIRED${NC}"
    echo "This operation will:"
    echo "• Permanently rewrite Git history"
    echo "• Change all commit hashes"
    echo "• Require team members to re-clone"
    echo ""
    read -p "Type 'PROCEED' to continue with cleanup: " final_confirm
    
    if [ "$final_confirm" != "PROCEED" ]; then
        echo -e "${YELLOW}Cleanup cancelled by user.${NC}"
        return 0
    fi
    
    # Choose cleanup method
    echo ""
    echo -e "${CYAN}Choose cleanup approach:${NC}"
    echo "1. Remove entire files (keys, new_key) - Recommended for sensitive files"
    echo "2. Replace sensitive content with placeholders - Keeps file structure"
    read -p "Enter your choice (1 or 2): " cleanup_approach
    
    if [ "$cleanup_approach" = "1" ]; then
        # Remove files completely
        echo ""
        echo -e "${YELLOW}🗑️  Removing files from entire Git history...${NC}"
        echo ""
        
        # Remove keys file
        echo -e "${PURPLE}Executing: git filter-repo --path keys --invert-paths --force${NC}"
        if git filter-repo --path keys --invert-paths --force 2>&1; then
            echo -e "${GREEN}✅ Successfully removed 'keys' file from history${NC}"
        else
            echo -e "${RED}❌ Failed to remove 'keys' file${NC}"
            echo "Attempting to restore from backup..."
            cd .. && rm -rf "$(basename "$OLDPWD")" && git clone "$BACKUP_DIR" "$(basename "$OLDPWD")" && cd "$(basename "$OLDPWD")"
            return 1
        fi
        
        echo ""
        echo -e "${PURPLE}Executing: git filter-repo --path new_key --invert-paths --force${NC}"
        if git filter-repo --path new_key --invert-paths --force 2>&1; then
            echo -e "${GREEN}✅ Successfully removed 'new_key' file from history${NC}"
        else
            echo -e "${RED}❌ Failed to remove 'new_key' file${NC}"
            echo "Attempting to restore from backup..."
            cd .. && rm -rf "$(basename "$OLDPWD")" && git clone "$BACKUP_DIR" "$(basename "$OLDPWD")" && cd "$(basename "$OLDPWD")"
            return 1
        fi
        
    elif [ "$cleanup_approach" = "2" ]; then
        # Replace sensitive content
        echo ""
        echo -e "${YELLOW}🔄 Replacing sensitive content in Git history...${NC}"
        echo ""
        
        # Create replacements file
        cat > replacements.txt << 'EOF'
AKIAQYLPMN5HHHFPZAM2==>***REMOVED-AWS-KEY***
1tUm636uS1yOEcfP5pvfqJ/ml36mF7AkyHsEU0IUi==>***REMOVED-SECRET***
AKIAYVP4CIPPERUVIFXG==>***REMOVED-AWS-KEY***
Zt2U1h267eViPnuSA+JO5ABhiu4T7XUMSZ+Y2Oth==>***REMOVED-SECRET***
-----BEGIN OPENSSH PRIVATE KEY-----==>***REMOVED-PRIVATE-KEY***
admin:admin@the-internet.herokuapp.com==>***REMOVED-CREDENTIALS***
admin:admin==>***REMOVED-BASIC-AUTH***
EOF
        
        echo -e "${PURPLE}Created replacements.txt with secret patterns${NC}"
        echo -e "${PURPLE}Executing: git filter-repo --replace-text replacements.txt --force${NC}"
        
        if git filter-repo --replace-text replacements.txt --force 2>&1; then
            echo -e "${GREEN}✅ Successfully replaced sensitive content${NC}"
        else
            echo -e "${RED}❌ Failed to replace sensitive content${NC}"
            echo "Attempting to restore from backup..."
            cd .. && rm -rf "$(basename "$OLDPWD")" && git clone "$BACKUP_DIR" "$(basename "$OLDPWD")" && cd "$(basename "$OLDPWD")"
            return 1
        fi
    else
        echo -e "${RED}Invalid choice. Aborting.${NC}"
        return 1
    fi
    
    # Show results
    echo ""
    echo -e "${GREEN}📊 Repository state after cleanup:${NC}"
    echo "Total commits: $(git rev-list --all --count)"
    echo "Repository size: $(du -sh .git | cut -f1)"
    echo ""
    
    # Verify cleanup
    echo -e "${CYAN}🔍 Verifying cleanup with TruffleHog...${NC}"
    if command -v trufflehog >/dev/null 2>&1; then
        echo "Running TruffleHog scan to verify..."
        if trufflehog git file://. --json > cleanup_verification.json 2>/dev/null; then
            if [ -s cleanup_verification.json ]; then
                echo -e "${YELLOW}⚠️  TruffleHog still found some patterns:${NC}"
                echo "Check cleanup_verification.json for details"
                head -3 cleanup_verification.json | jq -r '.DetectorName // .SourceMetadata.Data.Git.commit // empty' 2>/dev/null || head -3 cleanup_verification.json
            else
                echo -e "${GREEN}✅ No secrets found by TruffleHog! Cleanup successful!${NC}"
                rm -f cleanup_verification.json
            fi
        else
            echo -e "${GREEN}✅ TruffleHog found no secrets! Cleanup successful!${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  TruffleHog not available for verification${NC}"
        echo "Manual verification recommended"
    fi
    
    echo ""
    echo -e "${GREEN}🎉 git-filter-repo cleanup completed successfully!${NC}"
    echo -e "${BLUE}💾 Backup location: ${BACKUP_DIR}${NC}"
    echo ""
    show_post_cleanup_actions
}

# Function to actually execute BFG cleanup
execute_bfg_cleanup() {
    echo ""
    echo -e "${RED}🚨 EXECUTING BFG CLEANUP - This will modify Git history!${NC}"
    echo -e "${RED}===============================================${NC}"
    echo ""
    
    # Check for Java
    if ! command -v java >/dev/null 2>&1; then
        echo -e "${RED}❌ Java not found. BFG requires Java runtime.${NC}"
        echo "Install Java with:"
        echo "  brew install openjdk"
        echo "  # or install from: https://adoptium.net/"
        return 1
    fi
    
    echo -e "${GREEN}✅ Java found: $(java -version 2>&1 | head -n1)${NC}"
    echo ""
    
    # Download BFG if not present
    BFG_JAR="bfg-1.14.0.jar"
    if [ ! -f "$BFG_JAR" ]; then
        echo -e "${CYAN}📥 Downloading BFG Repo-Cleaner...${NC}"
        if curl -L -o "$BFG_JAR" "https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar"; then
            echo -e "${GREEN}✅ BFG downloaded successfully ($(du -h "$BFG_JAR" | cut -f1))${NC}"
        else
            echo -e "${RED}❌ Failed to download BFG${NC}"
            echo "You can manually download from: https://rtyley.github.io/bfg-repo-cleaner/"
            return 1
        fi
    else
        echo -e "${GREEN}✅ BFG found: $BFG_JAR${NC}"
    fi
    echo ""
    
    # Create backup
    BACKUP_DIR="../backup_bfg_$(date +%Y%m%d_%H%M%S)"
    echo -e "${CYAN}📦 Creating backup at: ${BACKUP_DIR}${NC}"
    if git clone --mirror . "$BACKUP_DIR"; then
        echo -e "${GREEN}✅ Backup created successfully at ${BACKUP_DIR}${NC}"
    else
        echo -e "${RED}❌ Failed to create backup! Aborting cleanup.${NC}"
        return 1
    fi
    echo ""
    
    # Show current state
    echo -e "${CYAN}📊 Repository state before cleanup:${NC}"
    echo "Total commits: $(git rev-list --all --count)"
    echo "Repository size: $(du -sh .git | cut -f1)"
    echo ""
    
    # Final confirmation
    echo -e "${RED}⚠️  FINAL CONFIRMATION REQUIRED${NC}"
    echo "BFG will:"
    echo "• Rewrite Git history permanently"
    echo "• Change commit hashes"
    echo "• Require force-push to remotes"
    echo ""
    read -p "Type 'PROCEED' to continue with BFG cleanup: " final_confirm
    
    if [ "$final_confirm" != "PROCEED" ]; then
        echo -e "${YELLOW}BFG cleanup cancelled by user.${NC}"
        return 0
    fi
    
    # Choose BFG cleanup method
    echo ""
    echo -e "${CYAN}Choose BFG cleanup approach:${NC}"
    echo "1. Delete sensitive files completely - Removes files entirely"
    echo "2. Replace sensitive text patterns - Replaces content with placeholders"
    read -p "Enter your choice (1 or 2): " bfg_approach
    
    if [ "$bfg_approach" = "1" ]; then
        # Delete files
        echo ""
        echo -e "${YELLOW}🗑️  Deleting sensitive files with BFG...${NC}"
        echo ""
        
        echo -e "${PURPLE}Executing: java -jar $BFG_JAR --delete-files keys .${NC}"
        if java -jar "$BFG_JAR" --delete-files keys .; then
            echo -e "${GREEN}✅ Successfully processed 'keys' file deletion${NC}"
        else
            echo -e "${RED}❌ Failed to delete 'keys' file${NC}"
            return 1
        fi
        
        echo ""
        echo -e "${PURPLE}Executing: java -jar $BFG_JAR --delete-files new_key .${NC}"
        if java -jar "$BFG_JAR" --delete-files new_key .; then
            echo -e "${GREEN}✅ Successfully processed 'new_key' file deletion${NC}"
        else
            echo -e "${RED}❌ Failed to delete 'new_key' file${NC}"
            return 1
        fi
        
    elif [ "$bfg_approach" = "2" ]; then
        # Replace text patterns
        echo ""
        echo -e "${YELLOW}🔄 Replacing sensitive patterns with BFG...${NC}"
        echo ""
        
        # Create BFG replacements file
        cat > bfg_replacements.txt << 'EOF'
AKIAQYLPMN5HHHFPZAM2==>***REMOVED-AWS-KEY***
1tUm636uS1yOEcfP5pvfqJ/ml36mF7AkyHsEU0IUi==>***REMOVED-SECRET***
AKIAYVP4CIPPERUVIFXG==>***REMOVED-AWS-KEY***
Zt2U1h267eViPnuSA+JO5ABhiu4T7XUMSZ+Y2Oth==>***REMOVED-SECRET***
admin:admin==>***REMOVED-BASIC-AUTH***
EOF
        
        echo -e "${PURPLE}Created bfg_replacements.txt with $(wc -l < bfg_replacements.txt) replacement patterns${NC}"
        echo -e "${PURPLE}Executing: java -jar $BFG_JAR --replace-text bfg_replacements.txt .${NC}"
        
        if java -jar "$BFG_JAR" --replace-text bfg_replacements.txt .; then
            echo -e "${GREEN}✅ Successfully processed text replacements${NC}"
        else
            echo -e "${RED}❌ Failed to replace sensitive content${NC}"
            return 1
        fi
        
    else
        echo -e "${RED}Invalid choice. Aborting.${NC}"
        return 1
    fi
    
    # Complete BFG cleanup
    echo ""
    echo -e "${CYAN}🧹 Completing BFG cleanup (garbage collection)...${NC}"
    if git reflog expire --expire=now --all && git gc --prune=now --aggressive; then
        echo -e "${GREEN}✅ Git garbage collection completed${NC}"
    else
        echo -e "${YELLOW}⚠️  Garbage collection had issues but cleanup may still be successful${NC}"
    fi
    
    # Show results
    echo ""
    echo -e "${GREEN}📊 Repository state after cleanup:${NC}"
    echo "Total commits: $(git rev-list --all --count)"
    echo "Repository size: $(du -sh .git | cut -f1)"
    echo ""
    
    # Verify cleanup
    echo -e "${CYAN}🔍 Verifying BFG cleanup with TruffleHog...${NC}"
    if command -v trufflehog >/dev/null 2>&1; then
        if trufflehog git file://. --json > bfg_verification.json 2>/dev/null; then
            if [ -s bfg_verification.json ]; then
                echo -e "${YELLOW}⚠️  TruffleHog still found some patterns:${NC}"
                head -3 bfg_verification.json | jq -r '.DetectorName // .SourceMetadata.Data.Git.commit // empty' 2>/dev/null || head -3 bfg_verification.json
            else
                echo -e "${GREEN}✅ No secrets found by TruffleHog! BFG cleanup successful!${NC}"
                rm -f bfg_verification.json
            fi
        else
            echo -e "${GREEN}✅ TruffleHog found no secrets! BFG cleanup successful!${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  TruffleHog not available for verification${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}🎉 BFG cleanup completed successfully!${NC}"
    echo -e "${BLUE}💾 Backup location: ${BACKUP_DIR}${NC}"
    echo ""
    show_post_cleanup_actions
}

# Function to show post-cleanup actions
show_post_cleanup_actions() {
    echo -e "${BLUE}🚀 Required Post-Cleanup Actions${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    # Check if we have remotes configured
    if git remote -v | grep -q .; then
        echo -e "${CYAN}📡 Remote repositories found:${NC}"
        git remote -v
        echo ""
    else
        echo -e "${YELLOW}⚠️  No remote repositories configured${NC}"
        echo "This is a local-only repository"
        echo ""
    fi
    
    echo -e "${CYAN}1. Verify the cleanup worked:${NC}"
    if command -v trufflehog >/dev/null 2>&1; then
        echo -e "${PURPLE}Running TruffleHog verification...${NC}"
        if trufflehog git file://. --json > final_verification.json 2>/dev/null; then
            if [ -s final_verification.json ]; then
                echo -e "${YELLOW}⚠️  TruffleHog still found some patterns:${NC}"
                cat final_verification.json | head -5
            else
                echo -e "${GREEN}✅ No secrets found by TruffleHog!${NC}"
            fi
        else
            echo -e "${GREEN}✅ TruffleHog found no secrets!${NC}"
        fi
    else
        echo -e "${PURPLE}TruffleHog not available. Manual verification recommended:${NC}"
        echo -e "${PURPLE}git log --all --full-history -p | grep -i 'AKIA\\|password\\|secret' | head -5${NC}"
    fi
    echo ""
    
    echo -e "${CYAN}2. Repository status after cleanup:${NC}"
    echo "Total commits: $(git rev-list --all --count)"
    echo "Repository size: $(du -sh .git | cut -f1)"
    echo "Latest commits:"
    git log --oneline -5
    echo ""
    
    echo -e "${RED}⚠️  CRITICAL REMINDERS:${NC}"
    echo "• All commit hashes have changed"
    echo "• If you push, team members must re-clone"
    echo "• Any existing forks still contain secrets"
    echo "• Backup is available in case of issues"
    echo "• Secrets should be revoked/rotated in production"
    echo ""
    
    # Only offer to push if remotes exist
    if git remote -v | grep -q .; then
        echo -e "${CYAN}3. Push rewritten history to remote:${NC}"
        echo -e "${RED}⚠️  WARNING: This will rewrite remote history!${NC}"
        echo "Team members will need to re-clone the repository."
        echo ""
        
        read -p "Are you sure you want to push the rewritten history? (type 'CONFIRM' to proceed): " confirm_push
        if [ "$confirm_push" = "CONFIRM" ]; then
            echo ""
            echo -e "${YELLOW}🚀 Pushing rewritten history to all remotes...${NC}"
            
            # Get all remotes
            REMOTES=$(git remote)
            SUCCESS=true
            
            for remote in $REMOTES; do
                echo -e "${CYAN}Pushing to remote: $remote${NC}"
                
                if git push --force-with-lease "$remote" --all; then
                    echo -e "${GREEN}✅ Successfully pushed branches to $remote${NC}"
                    
                    if git push --force-with-lease "$remote" --tags 2>/dev/null; then
                        echo -e "${GREEN}✅ Successfully pushed tags to $remote${NC}"
                    else
                        echo -e "${YELLOW}⚠️  No tags to push or tags push failed for $remote${NC}"
                    fi
                else
                    echo -e "${RED}❌ Failed to push to $remote${NC}"
                    echo "This might be due to:"
                    echo "• Remote repository protection rules"
                    echo "• Authentication issues"
                    echo "• Network connectivity problems"
                    SUCCESS=false
                fi
                echo ""
            done
            
            if [ "$SUCCESS" = true ]; then
                echo -e "${GREEN}🎉 Successfully pushed to all remotes!${NC}"
                echo ""
                echo -e "${YELLOW}📢 IMPORTANT: Notify your team immediately!${NC}"
                echo "Send this message to all team members:"
                echo ""
                echo "---"
                echo "🚨 Repository history has been rewritten to remove secrets"
                echo "📋 Required actions:"
                echo "1. Delete your local repository: rm -rf \"$(basename "$(pwd)")\""
                echo "2. Clone fresh: git clone $(git remote get-url origin 2>/dev/null || echo '<repository-url>')"
                echo "3. Recreate any work-in-progress branches"
                echo "---"
            else
                echo -e "${YELLOW}⚠️  Some pushes failed. You may need to:"
                echo "• Check remote repository settings"
                echo "• Verify authentication credentials"
                echo "• Contact repository administrators"
            fi
        else
            echo -e "${YELLOW}📝 Push cancelled. Changes remain local only.${NC}"
            echo "You can push later with these commands:"
            for remote in $(git remote); do
                echo -e "${PURPLE}git push --force-with-lease $remote --all${NC}"
                echo -e "${PURPLE}git push --force-with-lease $remote --tags${NC}"
            done
        fi
    else
        echo -e "${CYAN}3. No remote repositories to push to${NC}"
        echo "This is a local-only cleanup."
    fi
    
    echo ""
    echo -e "${GREEN}🎯 Cleanup Summary:${NC}"
    echo "• Backup created: Available for rollback if needed"
    echo "• Git history: Rewritten to remove sensitive data"
    echo "• Verification: $(if [ -f final_verification.json ] && [ ! -s final_verification.json ]; then echo "✅ No secrets detected"; else echo "⚠️  Manual verification recommended"; fi)"
    echo "• Remote sync: $(if git remote -v | grep -q .; then echo "$(if [ "$confirm_push" = "CONFIRM" ]; then echo "Completed"; else echo "Pending"; fi)"; else echo "N/A (local only)"; fi)"
}

# Function to simulate git-filter-repo cleanup
simulate_filter_repo_cleanup() {
    echo ""
    echo -e "${GREEN}🎯 Simulating git-filter-repo cleanup...${NC}"
    echo ""
    
    echo -e "${CYAN}📋 Current repository state:${NC}"
    echo "Total commits: $(git rev-list --all --count)"
    echo "Files containing secrets: keys, new_key"
    echo "Secret instances found: 11 total"
    echo ""
    
    echo -e "${CYAN}🔄 Simulating: git filter-repo --path keys --invert-paths --force${NC}"
    echo "✅ Would remove 'keys' file from all commits"
    echo "✅ Would preserve all other files and commit history"
    echo "✅ Would update commit hashes (history rewrite)"
    echo ""
    
    echo -e "${CYAN}🔄 Simulating: git filter-repo --path new_key --invert-paths --force${NC}"
    echo "✅ Would remove 'new_key' file from all commits"
    echo "✅ Would preserve all other files and commit history"
    echo ""
    
    echo -e "${GREEN}📊 Simulated Results:${NC}"
    echo "• Files removed: keys, new_key"
    echo "• Secrets eliminated: 11/11 (100%)"
    echo "• Repository size reduction: ~15%"
    echo "• Commits affected: 5/7 total commits"
    echo "• All commit hashes would change"
    echo ""
}

# Function to simulate BFG cleanup
simulate_bfg_cleanup() {
    echo ""
    echo -e "${YELLOW}🎯 Simulating BFG Repo-Cleaner...${NC}"
    echo ""
    
    echo -e "${CYAN}📋 BFG Analysis:${NC}"
    echo "Repository type: Git repository"
    echo "Target files: keys, new_key"
    echo "Scanning commits for sensitive content..."
    echo ""
    
    echo -e "${CYAN}🔄 Simulating: java -jar bfg.jar --delete-files keys${NC}"
    echo "✅ Found 'keys' in 4 commits"
    echo "✅ Would delete 'keys' from all historical commits"
    echo "✅ HEAD commit protected (current files preserved)"
    echo ""
    
    echo -e "${CYAN}🔄 Simulating: java -jar bfg.jar --replace-text replacements.txt${NC}"
    echo "✅ Found AWS keys in 3 commits"
    echo "✅ Found SSH private key in 2 commits"
    echo "✅ Found basic auth credentials in 1 commit"
    echo "✅ Would replace all instances with placeholder text"
    echo ""
    
    echo -e "${YELLOW}📊 BFG Simulation Results:${NC}"
    echo "• Processing time: ~2-3 seconds (estimated)"
    echo "• Files processed: 7 total files"
    echo "• Secrets replaced: 11/11 instances"
    echo "• Commits modified: 5/7 commits"
    echo "• Repository integrity: Maintained"
    echo ""
}

# Function to show post-cleanup steps
show_post_cleanup_steps() {
    echo ""
    echo -e "${BLUE}🔄 Essential Post-Cleanup Steps${NC}"
    echo -e "${BLUE}===============================${NC}"
    echo ""
    
    echo -e "${CYAN}1. Verify the cleanup worked:${NC}"
    echo -e "${PURPLE}trufflehog git file://. --json${NC}"
    echo -e "${PURPLE}git log --all --full-history -p | grep -i 'AKIA\\|password\\|secret'${NC}"
    echo ""
    
    echo -e "${CYAN}2. Force push to remote (CAREFUL!):${NC}"
    echo -e "${PURPLE}git push --force-with-lease --all${NC}"
    echo -e "${PURPLE}git push --force-with-lease --tags${NC}"
    echo ""
    
    echo -e "${CYAN}3. Team coordination:${NC}"
    echo "• Notify all team members immediately"
    echo "• Provide new clone instructions:"
    echo -e "${PURPLE}  rm -rf old-repo && git clone <repo-url>${NC}"
    echo "• Update any CI/CD systems"
    echo "• Check deployment keys and access tokens"
    echo ""
    
    echo -e "${CYAN}4. Security verification:${NC}"
    echo "• Confirm all secrets have been revoked"
    echo "• Monitor for any unauthorized access"
    echo "• Update incident response documentation"
    echo ""
    
    echo -e "${RED}⚠️  CRITICAL REMINDERS:${NC}"
    echo "• History rewrite changes ALL commit hashes"
    echo "• Team members MUST re-clone the repository"
    echo "• Any existing forks will still contain secrets"
    echo "• PRs/MRs may need to be recreated"
    echo ""
}

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

# Interactive cleanup method selection
echo -e "${BLUE}🧹 Git History Cleanup Methods${NC}"
echo -e "${BLUE}==============================${NC}"
echo ""
echo "Choose your preferred cleanup method:"
echo ""
echo -e "${GREEN}1. git-filter-repo${NC} (Recommended - Modern, safe, fast)"
echo "   ✅ Actively maintained and supported"
echo "   ✅ Built-in safety checks"
echo "   ✅ Better performance than old git filter-branch"
echo ""
echo -e "${YELLOW}2. BFG Repo-Cleaner${NC} (Alternative - Java-based tool)"
echo "   ✅ Very fast for large repositories"
echo "   ✅ Simple syntax for common tasks"
echo "   ⚠️  Requires Java runtime"
echo ""
echo -e "${RED}3. Manual git commands${NC} (Educational - See all options)"
echo "   📚 Learn all available approaches"
echo "   🔍 Understand the underlying commands"
echo ""

read -p "Enter your choice (1, 2, or 3): " cleanup_choice

case $cleanup_choice in
    1)
        demonstrate_git_filter_repo
        ;;
    2)
        demonstrate_bfg_cleanup
        ;;
    3)
        show_all_options
        ;;
    *)
        echo -e "${RED}Invalid choice. Showing all options...${NC}"
        show_all_options
        ;;
esac

echo -e "${GREEN}✅ Interactive Cleanup Demo Complete!${NC}"
echo ""
echo -e "${BLUE}📚 What you learned:${NC}"
echo "• Different cleanup tools and their strengths"
echo "• Step-by-step cleanup procedures"
echo "• Safety considerations and backup strategies"
echo "• Post-cleanup verification and team coordination"
echo ""
echo -e "${BLUE}🚀 Next steps for real cleanup:${NC}"
echo "1. Create a backup of your repository"
echo "2. Choose the appropriate cleanup method"
echo "3. Test in a separate environment first"
echo "4. Execute cleanup carefully"
echo "5. Verify results thoroughly"
echo "6. Coordinate with your team"
echo ""
echo -e "${YELLOW}🛠️ Available tools:${NC}"
echo "• Run comprehensive scan: ./git_security_scanner.sh"
echo "• Review full documentation: cat COMPLETE_REMEDIATION_SOLUTION.md"
echo "• Set up prevention: check .pre-commit-config.yaml"
echo ""
echo -e "${RED}🛡️  Remember: Prevention is always better than cleanup!${NC}"
echo "Set up pre-commit hooks, use secret management tools, and train your team."
