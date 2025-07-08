# Enhanced Manual Cleanup Demo Guide

## Overview
The enhanced `manual_cleanup_demo.sh` script provides an interactive way to clean secrets from Git history with **real execution capabilities**. This is no longer just a simulation - it can actually rewrite your Git history and push changes to remote repositories.

## 🚨 CRITICAL SAFETY NOTICE
This script will **permanently modify Git history** when you choose to execute cleanup operations. Always create backups and coordinate with your team before running.

## Features

### 1. Interactive Menu System
- **Option 1: git-filter-repo** (Recommended)
  - Modern, safe, and fast
  - Built-in safety checks
  - Handles edge cases well

- **Option 2: BFG Repo-Cleaner**
  - Very fast for large repositories
  - Requires Java runtime
  - Simple syntax for common tasks

- **Option 3: All Methods Overview**
  - Educational comparison
  - Shows all available approaches
  - Includes legacy methods

### 2. Real Execution Capabilities
- **Actual cleanup execution** (not simulation)
- **Backup creation** before any destructive operations
- **Verification** with TruffleHog after cleanup
- **Force-push to remotes** with user confirmation

### 3. Enhanced Safety Features
- Multiple confirmation prompts
- Automatic backup creation
- Error handling with rollback capability
- Pre-cleanup analysis and recommendations

## Usage

### Quick Start
```bash
# Test the setup first
./test_enhanced_demo.sh

# Run the interactive demo
./manual_cleanup_demo.sh
```

### Pre-Requirements
Install recommended tools:
```bash
# Essential for git-filter-repo method
brew install git-filter-repo

# For BFG method
brew install openjdk

# For verification
brew install trufflehog

# For better output formatting
brew install jq
```

## Step-by-Step Process

### 1. Repository Analysis
The script analyzes your repository and shows:
- Current secrets in working directory
- Commit history overview
- Secret patterns detected by TruffleHog
- Tool availability check

### 2. Method Selection
Choose your cleanup approach:
- **File removal**: Completely removes files from history
- **Content replacement**: Replaces secret patterns with placeholders

### 3. Safety Confirmations
Multiple safety prompts:
- Initial method confirmation
- Final execution confirmation (type 'PROCEED')
- Force-push confirmation (type 'CONFIRM')

### 4. Backup Creation
Automatic backup before any changes:
- git-filter-repo: `../backup_YYYYMMDD_HHMMSS`
- BFG: `../backup_bfg_YYYYMMDD_HHMMSS`

### 5. Cleanup Execution
Real operations performed:
- **git-filter-repo**: Removes files or replaces content
- **BFG**: Downloads JAR if needed, then cleans repository
- **Verification**: Runs TruffleHog to confirm cleanup

### 6. Post-Cleanup Actions
- Repository size and commit count comparison
- TruffleHog verification scan
- Remote push with team coordination messages

## Available Cleanup Methods

### Method 1: git-filter-repo (Recommended)
```bash
# Remove files completely
git filter-repo --path keys --invert-paths --force
git filter-repo --path new_key --invert-paths --force

# Replace content patterns
git filter-repo --replace-text replacements.txt --force
```

### Method 2: BFG Repo-Cleaner
```bash
# Remove files
java -jar bfg-1.14.0.jar --delete-files keys
java -jar bfg-1.14.0.jar --delete-files new_key

# Replace patterns
java -jar bfg-1.14.0.jar --replace-text replacements.txt
```

## What Gets Cleaned

### Secret Patterns Detected
- **AWS Access Keys**: `AKIAQYLPMN5HHHFPZAM2`, `AKIAYVP4CIPPERUVIFXG`
- **AWS Secret Keys**: `1tUm636uS1yOEcfP5pvfqJ/ml36mF7AkyHsEU0IUi`, `Zt2U1h267eViPnuSA+JO5ABhiu4T7XUMSZ+Y2Oth`
- **SSH Private Key**: Full OpenSSH private key in `keys` file
- **Basic Auth**: `admin:admin@the-internet.herokuapp.com`

### Files Affected
- `keys`: Contains AWS keys and SSH private key
- `new_key`: Contains additional AWS credentials

## Safety Features

### Automatic Backups
- Created before any destructive operation
- Full repository backup with all history
- Can be used to restore if needed

### Error Handling
- Rollback on failure
- Clear error messages
- Guidance for manual recovery

### Verification
- TruffleHog scan after cleanup
- Commit count and size comparison
- Manual verification instructions

## Team Coordination

### Before Cleanup
1. Notify all team members
2. Ensure no one is pushing changes
3. Plan for repository re-clone
4. Prepare credential rotation

### After Cleanup
The script provides team notification template:
```
🚨 Repository history has been rewritten to remove secrets
📋 Required actions:
1. Delete your local repository: rm -rf <repo-name>
2. Clone fresh: git clone <repository-url>
3. Recreate any work-in-progress branches
```

## Force Push Process

### Confirmation Required
- Type 'CONFIRM' to proceed with force-push
- Pushes to all configured remotes
- Handles both branches and tags

### What Happens
1. `git push --force-with-lease --all` for all remotes
2. `git push --force-with-lease --tags` for all remotes
3. Success/failure reporting for each remote

## Troubleshooting

### Common Issues

#### git-filter-repo not found
```bash
brew install git-filter-repo
# or
pip3 install git-filter-repo
```

#### Java not available (for BFG)
```bash
brew install openjdk
```

#### Force-push fails
- Check remote repository protection rules
- Verify authentication credentials
- Contact repository administrators

#### TruffleHog still finds secrets
- Review the patterns in replacements.txt
- Check for new secret formats
- Run additional cleanup cycles

### Recovery Options

#### Restore from backup
```bash
cd ..
rm -rf original-repo
git clone backup_YYYYMMDD_HHMMSS original-repo
cd original-repo
```

#### Manual verification
```bash
# Search for remaining secrets
git log --all -p | grep -i "AKIA\|password\|secret"

# Check specific patterns
git log --all -p | grep -E "(AKIA[0-9A-Z]{16}|-----BEGIN.*PRIVATE)"
```

## Best Practices

### Before Running
1. **Test in a separate environment first**
2. **Create manual backups**
3. **Coordinate with team**
4. **Have credentials ready to revoke**

### During Execution
1. **Read all prompts carefully**
2. **Verify backup creation**
3. **Check cleanup results**
4. **Coordinate team communication**

### After Cleanup
1. **Verify secret removal**
2. **Revoke/rotate credentials**
3. **Update team documentation**
4. **Monitor for unauthorized access**

## Integration with Other Tools

### Part of Complete Solution
- `git_security_scanner.sh`: Comprehensive scanning
- `.pre-commit-config.yaml`: Prevention hooks
- `.github/workflows/security.yml`: CI/CD scanning
- `COMPLETE_REMEDIATION_SOLUTION.md`: Full documentation

### Workflow Integration
```bash
# 1. Scan repository
./git_security_scanner.sh

# 2. Review findings
cat secret_scan_report.md

# 3. Execute cleanup
./manual_cleanup_demo.sh

# 4. Set up prevention
git add .pre-commit-config.yaml
pre-commit install
```

## Summary

The enhanced manual cleanup demo provides:
- **Real execution** of cleanup operations
- **Interactive guidance** through the process
- **Safety features** to prevent data loss
- **Team coordination** support
- **Verification** of cleanup success

Use this tool when you need to actually clean secrets from Git history, not just learn about the process. Always test in a safe environment first and coordinate with your team.

## Quick Reference

```bash
# Test setup
./test_enhanced_demo.sh

# Run cleanup
./manual_cleanup_demo.sh

# Follow prompts and confirmations
# Choose method: 1 (git-filter-repo), 2 (BFG), or 3 (educational)
# Confirm execution: type 'PROCEED'
# Confirm push: type 'CONFIRM'
```

Remember: **Prevention is better than cleanup!** Set up the pre-commit hooks and CI/CD scanning to prevent future secret exposure.
