# Security Workflows: How Data Protection Works

This document explains the technical details of how this template prevents accidental data leaks. It's designed for researchers who want to understand what's happening behind the scenes.

---

## Overview: Defense in Depth

We use **four independent layers** of protection. Each layer can be bypassed individually, but together they create a strong safety net:

```
Your Computer                          GitHub Server
─────────────────────────────────────────────────────────

git add ──→ .gitignore ──→ BLOCKED
            (Layer 1)

git commit ──→ pre-commit ──→ BLOCKED
               (Layer 2)

git push ──→ pre-push ──→ BLOCKED
             (Layer 3)

                    │
                    │ (if bypassed)
                    ↓
              GitHub Actions ──→ BLOCKED & ALERT
              (Layer 4)
```

**Key principle:** Even if you bypass local checks (accidentally or intentionally), GitHub Actions will catch violations and alert the security team.

---

## Layer 1: `.gitignore` - Passive Protection

**When it runs:** Before `git add`
**What it does:** Tells Git to ignore certain file patterns
**Enforcement:** Soft - can be bypassed with `git add -f`

The `.gitignore` file contains patterns for sensitive file types:

```gitignore
# Data files
*.csv
*.xlsx
*.RData

# Medical data
*.nii
*.dcm
*.edf

# Credentials
.env
*.pem
*.key
```

### How It Works

When you try to add a blocked file:

```bash
$ git add data.csv
# Git silently ignores it - no error, no commit
```

This is the **weakest layer** because:
- It can be overridden: `git add -f data.csv`
- It only affects new files (files already tracked are not blocked)
- It gives no warning when blocking files

**That's why we have three more layers.**

---

## Layer 2: Pre-Commit Hook - Active Protection

**When it runs:** Every time you type `git commit`
**What it does:** Scans staged files before creating a commit
**Enforcement:** Strong - blocks commit unless bypassed with `--no-verify`

### Installation Required

```bash
pip install pre-commit
pre-commit install
```

### What Gets Checked

The pre-commit hook runs multiple checks:

#### 1. Forbidden File Types
**Hook:** `check-forbidden-filetypes`
**Scans for:** Data files, medical imaging, genomics, credentials

Example output when blocked:

```
❌ check-forbidden-filetypes................................................Failed
- hook id: check-forbidden-filetypes
- exit code: 1

Forbidden file detected: data/patients.csv
   Blocked by: *.csv pattern in central-gitignore.txt

   This file cannot be committed. Data files must stay in
   your local /data folder.

   If you believe this is an error, contact your data steward.
```

#### 2. Personal Information Detection
**Hook:** `check-personal-info`
**Scans for:**
- Dutch names (common first names and surnames)
- Dutch addresses (street patterns, postal codes)
- Patient IDs (MRN patterns)
- BSN (Burgerservicenummer)
- Medical record numbers

This hook uses pattern matching and Dutch name databases to detect:

```python
# Examples of what gets flagged:
"Jan de Vries, 1234 AB Amsterdam"     # Name + address
"Patient MRN: 20241234"                # Medical record number
"BSN: 123456782"                       # BSN format
```

Example output:

```
❌ check-personal-info.....................................................Failed
- hook id: check-personal-info
- exit code: 1

Personal information detected in: scripts/analysis.R

Line 45: Jan de Vries, Postbus 1234, 1012 AB Amsterdam
         ^^^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
         Dutch name    Dutch address pattern

This appears to contain personally identifiable information.
Please remove or anonymize before committing.
```

#### 3. Standard Checks

Additional quality checks from `pre-commit-hooks`:

| Hook | Purpose |
|------|---------|
| `trailing-whitespace` | Removes trailing spaces |
| `end-of-file-fixer` | Ensures files end with newline |
| `check-added-large-files` | Warns about files >100KB |
| `check-merge-conflict` | Blocks unresolved merge markers |

### Technical Details

The hooks are defined in `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/AmsterdamUMC/org-security-workflows
    rev: v0.2.21
    hooks:
      - id: check-forbidden-filetypes
        stages: [pre-commit]
      - id: check-personal-info
        stages: [pre-commit]
```

These reference **centralized security rules** in the `org-security-workflows` repository, which means:
- Rules are consistent across all Amsterdam UMC projects
- Security updates apply to all repositories automatically
- No need to maintain rules in every project

---

## Layer 3: Pre-Push Hook - Final Local Check

**When it runs:** Every time you type `git push`
**What it does:** Re-scans all commits about to be pushed
**Enforcement:** Strong - blocks push unless bypassed with `--no-verify`

### Why Pre-Push Matters

Pre-commit checks individual commits as you create them. Pre-push checks **everything** you're about to send to GitHub, including:
- Commits made before pre-commit was installed
- Commits made on other machines
- Commits where pre-commit was bypassed

### Installation

```bash
pre-commit install --hook-type pre-push
```

### What Gets Checked

Same checks as pre-commit, but runs on **all commits in the push**, not just staged files:

```yaml
repos:
  - repo: https://github.com/AmsterdamUMC/org-security-workflows
    rev: v0.2.21
    hooks:
      - id: check-forbidden-filetypes-prepush
        stages: [pre-push]
      - id: check-personal-info-prepush
        stages: [pre-push]
```

This is your **last chance** to catch issues before data leaves your computer.

---

## Layer 4: GitHub Actions - Server-Side Enforcement

**When it runs:** Every push to `main`/`master` and every pull request
**What it does:** Server-side validation that cannot be bypassed
**Enforcement:** Absolute - failures block PRs and trigger security alerts

### Workflow Definition

`.github/workflows/security-check.yml`:

```yaml
name: Org Security Scan
on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  filetype-check:
    uses: AmsterdamUMC/org-security-workflows/.github/workflows/check-forbidden-filetypes.yml@main
    secrets: inherit

  personal-info-check:
    uses: AmsterdamUMC/org-security-workflows/.github/workflows/check-personal-info.yml@main
    secrets: inherit
```

### What Happens on Violation

If forbidden files are detected:

1. **Pull Request is blocked**
   - Red ❌ appears on PR
   - "Required checks failed"
   - PR cannot be merged

2. **Security alert triggered**
   - Security team receives automated notification
   - Alert includes:
     - Repository name
     - File(s) that triggered violation
     - Committer information
     - Timestamp

3. **Issue created for tracking**
   - Automatic GitHub issue opened
   - Assigned to repository maintainers
   - Contains remediation checklist

4. **You are contacted**
   - Email notification
   - Guidance on next steps
   - Help with history cleanup if needed

### Why This Layer Can't Be Bypassed

Unlike local hooks:
- Runs on GitHub's servers (not your computer)
- No `--no-verify` flag exists
- Required checks must pass before merging
- Enforced at the organization level

**This is your safety net when local checks fail.**

---

## Centralized Security Management

All security rules live in the `AmsterdamUMC/org-security-workflows` repository:

```
org-security-workflows/
├── .github/workflows/
│   ├── check-forbidden-filetypes.yml
│   └── check-personal-info.yml
├── hooks/
│   ├── check-forbidden-filetypes
│   └── check-personal-info
├── configs/
│   ├── central-gitignore.txt
│   ├── dutch-names.txt
│   └── pii-patterns.json
└── .pre-commit-hooks.yaml
```

### Benefits

1. **Consistency** - All projects use identical rules
2. **Maintainability** - Update rules once, apply everywhere
3. **Auditability** - Single source of truth for compliance
4. **Version control** - Rules are versioned (v0.2.21)

When we update security rules:
- Bump version in `org-security-workflows`
- Update `rev:` in your `.pre-commit-config.yaml`
- Run `pre-commit autoupdate`

---

## What Can Still Go Wrong?

Even with four layers, issues can occur:

### Scenario 1: All Hooks Bypassed

```bash
# Someone deliberately bypasses all checks
git add -f sensitive.csv
git commit --no-verify -m "force commit"
git push --no-verify
```

**Result:** GitHub Actions catches it and blocks the PR + alerts security team.

### Scenario 2: False Negatives

The system might miss:
- Encrypted files containing sensitive data
- Base64-encoded credentials
- Data in uncommon formats not in `.gitignore`
- Creative obfuscation attempts

**Mitigation:**
- Regular security audits
- Educate researchers on intent, not just rules
- Encourage reporting near-misses

### Scenario 3: False Positives

The system might block legitimate files:
- Configuration `.json` files
- Test data that looks like real names
- Public datasets

**Solution:**
- Exceptions can be added to central config
- Contact security team for review
- Use `# nosecret` comments (if supported)

---

## Best Practices

### For Daily Use

1. **Review before committing**
   ```bash
   git diff --staged  # See what you're about to commit
   ```

2. **Commit often, push less frequently**
   - Pre-commit runs per commit (fast)
   - Pre-push scans everything (slower)

3. **Don't bypass unless you understand why**
   - `--no-verify` defeats the purpose
   - If you need to bypass, ask yourself: "Why is this being blocked?"

### For Setup

1. **Install both hooks**
   ```bash
   pre-commit install
   pre-commit install --hook-type pre-push
   ```

2. **Test your setup**
   ```bash
   echo "test" > test.csv
   git add test.csv
   git commit -m "test"  # Should fail
   ```

3. **Keep hooks updated**
   ```bash
   pre-commit autoupdate
   ```

### For Collaboration

1. **All contributors must install hooks** - Add to onboarding checklist
2. **Document exceptions** - If you need to whitelist files, document why
3. **Report issues** - If hooks fail incorrectly, help improve them

---

## Troubleshooting

### "pre-commit: command not found"

```bash
pip install pre-commit
# or
pip3 install pre-commit
```

### Hooks don't run

```bash
# Re-install hooks
pre-commit uninstall
pre-commit install
pre-commit install --hook-type pre-push

# Verify installation
ls .git/hooks/pre-commit   # Should exist
ls .git/hooks/pre-push     # Should exist
```

### Hook runs but doesn't block

Check if hooks are executable:

```bash
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-push
```

### "Hook failed to run" errors

Update pre-commit:

```bash
pre-commit autoupdate
pre-commit run --all-files  # Test
```

### GitHub Action fails unexpectedly

1. Check workflow run logs in GitHub Actions tab
2. Look for specific file that triggered failure
3. Contact security team if unclear

---

## Summary: Your Responsibilities

As a researcher using this template:

**Required:**
- Install pre-commit hooks on your machine
- Keep repositories private unless approved
- Never bypass hooks without understanding why
- Report security incidents immediately

**Recommended:**
- Review staged changes before committing
- Test hooks after setup
- Update hooks periodically
- Read error messages carefully

**Never:**
- Force-add blocked files without approval
- Share credentials in code or config
- Make repositories public without review
- Ignore security warnings

---

## Questions?

- **Technical issues:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
- **Policy questions:** Contact your data steward
- **False positives:** Open issue in `org-security-workflows` repo
- **Security incidents:** See [SECURITY.md](../SECURITY.md)

---

_Remember: These systems exist to help you, not hinder you. If something seems wrong or blocks legitimate work, reach out - we want to make this better._
