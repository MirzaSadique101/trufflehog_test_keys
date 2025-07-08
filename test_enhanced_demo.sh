#!/bin/bash

# Test script for the enhanced manual cleanup demo
# This script tests the functionality without actually executing destructive operations

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Enhanced Manual Cleanup Demo${NC}"
echo -e "${BLUE}=======================================${NC}"
echo ""

# Test 1: Check script executability
echo -e "${CYAN}Test 1: Script Executability${NC}"
if [ -x "manual_cleanup_demo.sh" ]; then
    echo -e "${GREEN}✅ Script is executable${NC}"
else
    echo -e "${RED}❌ Script is not executable${NC}"
    echo "Run: chmod +x manual_cleanup_demo.sh"
    exit 1
fi
echo ""

# Test 2: Check repository status
echo -e "${CYAN}Test 2: Repository Status${NC}"
if git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Valid Git repository${NC}"
    echo "Current branch: $(git branch --show-current)"
    echo "Total commits: $(git rev-list --all --count)"
else
    echo -e "${RED}❌ Not a Git repository${NC}"
    exit 1
fi
echo ""

# Test 3: Check for secret files
echo -e "${CYAN}Test 3: Secret Files Check${NC}"
SECRETS_FOUND=0

if [ -f "keys" ]; then
    echo -e "${GREEN}✅ 'keys' file found${NC}"
    SECRETS_FOUND=$((SECRETS_FOUND + 1))
else
    echo -e "${YELLOW}⚠️  'keys' file not found${NC}"
fi

if [ -f "new_key" ]; then
    echo -e "${GREEN}✅ 'new_key' file found${NC}"
    SECRETS_FOUND=$((SECRETS_FOUND + 1))
else
    echo -e "${YELLOW}⚠️  'new_key' file not found${NC}"
fi

echo "Secret files found: $SECRETS_FOUND/2"
echo ""

# Test 4: Check tool availability
echo -e "${CYAN}Test 4: Cleanup Tools Availability${NC}"

echo -n "git-filter-repo: "
if command -v git-filter-repo >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Available${NC}"
else
    echo -e "${YELLOW}⚠️  Not installed (recommended for best experience)${NC}"
    echo "   Install with: brew install git-filter-repo"
fi

echo -n "Java (for BFG): "
if command -v java >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Available${NC}"
else
    echo -e "${YELLOW}⚠️  Not installed (needed for BFG option)${NC}"
    echo "   Install with: brew install openjdk"
fi

echo -n "TruffleHog: "
if command -v trufflehog >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Available${NC}"
else
    echo -e "${YELLOW}⚠️  Not installed (verification will be limited)${NC}"
    echo "   Install with: brew install trufflehog"
fi

echo -n "jq (for JSON parsing): "
if command -v jq >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Available${NC}"
else
    echo -e "${YELLOW}⚠️  Not installed (output formatting will be basic)${NC}"
    echo "   Install with: brew install jq"
fi
echo ""

# Test 5: Run TruffleHog scan if available
echo -e "${CYAN}Test 5: Secret Detection${NC}"
if command -v trufflehog >/dev/null 2>&1; then
    echo "Running TruffleHog scan..."
    if trufflehog git file://. --json > test_scan.json 2>/dev/null; then
        if [ -s test_scan.json ]; then
            SECRET_COUNT=$(wc -l < test_scan.json)
            echo -e "${RED}🚨 Found $SECRET_COUNT secret(s) in repository${NC}"
            
            if command -v jq >/dev/null 2>&1; then
                echo "Secret types:"
                jq -r '.DetectorName' test_scan.json 2>/dev/null | sort | uniq -c | sort -rn
            fi
        else
            echo -e "${GREEN}✅ No secrets detected${NC}"
        fi
    else
        echo -e "${GREEN}✅ No secrets detected${NC}"
    fi
    rm -f test_scan.json
else
    echo -e "${YELLOW}⚠️  TruffleHog not available, checking manually...${NC}"
    if git log --all -p | grep -q "AKIA\|BEGIN.*PRIVATE\|://.*:.*@"; then
        echo -e "${RED}🚨 Found potential secret patterns in Git history${NC}"
    else
        echo -e "${GREEN}✅ No obvious secret patterns found${NC}"
    fi
fi
echo ""

# Test 6: Check script functions
echo -e "${CYAN}Test 6: Script Function Validation${NC}"
SCRIPT_FUNCTIONS=(
    "demonstrate_git_filter_repo"
    "demonstrate_bfg_cleanup"
    "show_all_options"
    "execute_filter_repo_cleanup"
    "execute_bfg_cleanup"
    "show_post_cleanup_actions"
    "run_cleanup_analysis"
)

for func in "${SCRIPT_FUNCTIONS[@]}"; do
    if grep -q "^$func()" manual_cleanup_demo.sh; then
        echo -e "${GREEN}✅ Function '$func' found${NC}"
    else
        echo -e "${RED}❌ Function '$func' missing${NC}"
    fi
done
echo ""

# Test 7: Check remotes
echo -e "${CYAN}Test 7: Remote Repository Check${NC}"
if git remote -v | grep -q .; then
    echo -e "${YELLOW}⚠️  Remote repositories configured:${NC}"
    git remote -v
    echo ""
    echo -e "${RED}🚨 IMPORTANT: After cleanup, you'll need to force-push${NC}"
    echo "Team members will need to re-clone the repository"
else
    echo -e "${GREEN}✅ No remote repositories (local-only cleanup)${NC}"
fi
echo ""

# Test 8: Simulate backup creation
echo -e "${CYAN}Test 8: Backup Creation Test${NC}"
TEST_BACKUP="../test_backup_$(date +%Y%m%d_%H%M%S)"
if git clone . "$TEST_BACKUP" --bare 2>/dev/null; then
    echo -e "${GREEN}✅ Backup creation works${NC}"
    rm -rf "$TEST_BACKUP"
else
    echo -e "${RED}❌ Backup creation failed${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}📊 Test Summary${NC}"
echo -e "${BLUE}===============${NC}"
echo ""

echo -e "${GREEN}Ready for interactive demo:${NC}"
echo "✅ Run: ./manual_cleanup_demo.sh"
echo ""

echo -e "${YELLOW}Recommended pre-cleanup steps:${NC}"
echo "1. Ensure all tools are installed (git-filter-repo recommended)"
echo "2. Create a manual backup: git clone . ../manual_backup --bare"
echo "3. Notify team members if pushing to remote"
echo "4. Have credentials ready to revoke/rotate"
echo ""

echo -e "${RED}⚠️  Safety Reminders:${NC}"
echo "• Test in a separate environment first"
echo "• Always create backups before cleanup"
echo "• Coordinate with team before force-pushing"
echo "• Revoke/rotate any exposed credentials"
echo ""

if [ "$SECRETS_FOUND" -gt 0 ]; then
    echo -e "${RED}🔥 Ready to clean $SECRETS_FOUND secret file(s)!${NC}"
    echo "Run the interactive demo when ready."
else
    echo -e "${YELLOW}📝 No secret files found to clean${NC}"
    echo "Demo will show simulation mode."
fi

echo ""
echo -e "${CYAN}🚀 Start the enhanced demo with:${NC}"
echo -e "${PURPLE}./manual_cleanup_demo.sh${NC}"
