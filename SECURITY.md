# Security Policy

This repository is part of the Amsterdam UMC research environment. To protect patient privacy and research integrity, we enforce strict security controls throughout the Git development lifecycle.

**Version:** 1.1
**Last Updated:** January 2026
**Contact:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)

---

## Table of Contents

- [Scope](#scope)
- [Protection Architecture](#protection-architecture)
- [Forbidden Content](#forbidden-content)
- [Setup Instructions](#setup-instructions)
- [Best Practices](#best-practices)
- [Incident Response](#incident-response)
- [Repository Access Control](#repository-access-control)
- [Reporting Vulnerabilities](#reporting-vulnerabilities)

---

## Scope

### In Scope

This policy covers **GitHub-related security threats**, including:

- Accidental commits of patient data, research datasets, or confidential information
- Exposure of credentials, API keys, tokens, or passwords
- Unauthorized access to private repositories
- Sensitive data persisting in Git history
- Personal identifiable information (PII) in code or documentation

### Out of Scope

Data handling **within secure processing environments** is covered by separate policies:

- myDRE (Medical Research Data Environment)
- SURF Research Cloud
- Amsterdam UMC secure servers
- Local workstation security

**However:** Moving data **from** these environments **to** GitHub is in scope and must comply with this policy.

---

## Protection Architecture

We implement a **defense-in-depth** strategy with four independent layers:

### Layer 1: `.gitignore` (Passive Prevention)

**Purpose:** Prevent Git from tracking sensitive file types
**Strength:** Weak - can be overridden with `-f` flag
**Scope:** New files only (doesn't affect already-tracked files)

Contains patterns for:
- Data files (`.csv`, `.xlsx`, `.RData`, etc.)
- Medical formats (`.nii`, `.dcm`, `.edf`, etc.)
- Credentials (`.env`, `.key`, `.pem`, etc.)

### Layer 2: Pre-Commit Hook (Active Prevention)

**Purpose:** Block commits containing forbidden content
**Strength:** Strong - requires `--no-verify` to bypass
**Scope:** Files staged for commit

Checks performed:
1. **Forbidden file types** - Blocks data files and credentials
2. **Personal information** - Scans for Dutch names, addresses, patient IDs, BSN
3. **Large files** - Warns about files >100KB
4. **Code quality** - Trailing whitespace, merge conflicts

### Layer 3: Pre-Push Hook (Final Local Check)

**Purpose:** Validate all commits before they leave your machine
**Strength:** Strong - requires `--no-verify` to bypass
**Scope:** All commits in the push (not just new ones)

This catches:
- Commits made before hooks were installed
- Commits made on other machines
- Previously bypassed commits

### Layer 4: GitHub Actions (Mandatory Enforcement)

**Purpose:** Server-side validation that cannot be bypassed
**Strength:** Absolute - no way to override
**Scope:** Every push and pull request

Actions taken on violation:
1. Pull request blocked (cannot merge)
2. Security team alerted automatically
3. Tracking issue created
4. Committer contacted for remediation

**This is the safety net when local checks fail or are bypassed.**

---

## Forbidden Content

The following content is **prohibited** from being committed to any Amsterdam UMC GitHub repository:

###  Data Files

**All formats that commonly contain research or patient data:**

| Category | File Extensions | Why Blocked |
|----------|-----------------|-------------|
| **Tabular data** | `.csv`, `.tsv`, `.txt`, `.dat` | May contain patient records |
| **Spreadsheets** | `.xlsx`, `.xls`, `.ods` | May contain identifiable data |
| **Statistical formats** | `.sav`, `.dta`, `.RData`, `.rds`, `.sas7bdat`, `.xpt`, `.por` | SPSS, Stata, R, SAS data files |
| **Binary formats** | `.feather`, `.parquet`, `.pickle`, `.pkl` | Serialized data structures |
| **HDF5** | `.h5`, `.hdf5`, `.he5`, `.fast5` | Scientific data containers |
| **Databases** | `.sqlite`, `.db`, `.sql` | Database dumps and schemas |

**Rationale:** These files are designed to store data. Even "anonymized" data may contain re-identification risks.

###  Medical & Research Data

**Specialized formats used in healthcare and life sciences:**

| Category | File Extensions | Why Blocked |
|----------|-----------------|-------------|
| **Neuroimaging** | `.nii`, `.nii.gz`, `.dcm`, `.ima` | Brain scans (DICOM, NIfTI) |
| **Biosignals** | `.edf`, `.bdf`, `.eeg`, `.vhdr`, `.vmrk`, `.cnt` | EEG, ECG, physiological data |
| **Genomics** | `.fastq`, `.fastq.gz`, `.fasta`, `.bam`, `.sam`, `.vcf`, `.vcf.gz`, `.bed`, `.gtf`, `.gff` | DNA/RNA sequencing data |
| **Microscopy** | `.czi`, `.lif`, `.nd2`, `.tif` (large) | Imaging data |

**Rationale:** These files inherently contain patient/subject data and are often large.

### Personal Identifiable Information (PII)

**Content detected by pattern matching:**

| Type | Examples | Detection Method |
|------|----------|------------------|
| **Dutch names** | Jan de Vries, Marja van der Berg | Database of common Dutch names |
| **Dutch addresses** | Postbus 1234, 1012 AB Amsterdam | Postal code patterns, street keywords |
| **Patient IDs** | MRN: 20241234, Patient #12345 | Medical record number patterns |
| **BSN** | 123456782 (with checksum) | Dutch social security number format |
| **Email addresses** | patient@email.com in data context | Email patterns in suspicious contexts |
| **Phone numbers** | +31 6 12345678 in data context | Dutch phone number patterns |

**Rationale:** Even without names, combinations of attributes can re-identify individuals.

**Important:** The PII scanner looks for **patterns**, not just exact matches. Code that processes PII (e.g., anonymization scripts) may trigger false positives - this is intentional and requires manual review.

###  Credentials & Secrets

**Authentication and encryption materials:**

| Type | Examples | Why Blocked |
|------|----------|-------------|
| **Environment files** | `.env`, `.env.local`, `.env.production`, `.env.*` | Contain API keys, passwords, connection strings |
| **Private keys** | `.key`, `.pem`, `.pfx`, `.p12`, `.jks` | Encryption and SSL/TLS keys |
| **SSH keys** | `id_rsa`, `id_ed25519`, `id_ecdsa` | Server access credentials |
| **Certificates** | `.crt`, `.cer`, `.p7b` | May contain private keys or sensitive info |
| **Config files** | `*.config` with secrets, `secrets.json`, `credentials.xml` | Application configurations with embedded secrets |
| **Service accounts** | `serviceAccount.json`, `*.pem` (GCP, AWS) | Cloud service credentials |

**Rationale:** Exposed credentials enable unauthorized access. Even "test" credentials can be exploited.

**Note:** Public certificates and sanitized config templates are allowed - the scanner looks for patterns indicating private keys or secrets.

###  Other Prohibited Content

| Category | File Extensions | Why Blocked |
|----------|-----------------|-------------|
| **Archives** | `.zip`, `.tar`, `.tar.gz`, `.7z`, `.rar` | May contain any of the above |
| **Media files** | `.mp4`, `.avi`, `.mov`, `.wav` (large) | May contain patient recordings or identifiable information |
| **Backup files** | `.bak`, `~`, `.swp`, `.tmp` | May contain sensitive data from original files |

---

## Setup Instructions

### Required for All Contributors

Every person with write access **must** install pre-commit hooks:

#### Step 1: Install Pre-Commit

```bash
# Using pip
pip install pre-commit

# Or using conda
conda install -c conda-forge pre-commit

# Or using homebrew (macOS)
brew install pre-commit
```

#### Step 2: Enable Hooks in Your Repository

Navigate to your project folder and run:

```bash
# Enable commit-time checks
pre-commit install

# Enable push-time checks (important!)
pre-commit install --hook-type pre-push
```

#### Step 3: Verify Installation

Test that hooks work correctly:

```bash
# Create a test file that should be blocked
echo "test data" > test.csv

# Try to commit it
git add test.csv
git commit -m "test"

# Expected output:
# check-forbidden-filetypes................................Failed
# The commit should be blocked

# Clean up
rm test.csv
git reset
```

If the commit succeeds, **hooks are not installed correctly**. Repeat step 2.

#### Step 4: Run Initial Scan

Scan your existing repository:

```bash
# Check all files (may take a few minutes)
pre-commit run --all-files
```

Fix any violations before continuing work.

### For Repository Administrators

Additional setup for new repositories:

1. **Enable branch protection rules**
   - Settings → Branches → Add rule
   - Require status checks: "Org Security Scan"
   - Require branches to be up to date

2. **Configure CODEOWNERS**
   - Add security-aware reviewers
   - Require review for security-sensitive paths

3. **Set repository to private**
   - Settings → Danger Zone → Change visibility
   - Public repos require additional approval

4. **Enable vulnerability alerts**
   - Settings → Security & analysis
   - Enable Dependabot alerts

---

## Best Practices

### Data Handling

#### DO

- **Use the `/data/` folder** for local data files

  ```bash
  project/
  ├── data/          # Git-ignored, safe for sensitive data
  │   ├── raw/
  │   └── processed/
  ```

- **Document data sources** in `/data/README.md`
  - Where it came from
  - How to access secure storage
  - Expected file structure
  - **Do not include actual file paths or credentials**

- **Use environment variables** for configuration

  ```python
  # Good
  import os
  db_password = os.environ.get('DB_PASSWORD')

  # Bad
  db_password = "hardcoded_password_123"
  ```

- **Use placeholder data** in examples

  ```python
  # Good - clearly fake
  example_data = pd.DataFrame({
      'patient_id': ['PAT001', 'PAT002'],
      'age': [45, 52]
  })
  ```

#### DON'T

- **Don't scatter data files** throughout the project

  ```bash
  project/
  ├── scripts/
  │   └── temp_data.csv    # Will be committed!
  ├── analysis.xlsx        # Will be committed!
  ```

- **Don't hardcode paths** that reveal file locations

  ```python
  # Bad - reveals network structure
  data = pd.read_csv('//myDRE/projects/secret_project/data.csv')

  # Good - uses environment variable
  data_path = os.environ.get('DATA_PATH')
  data = pd.read_csv(data_path)
  ```

- **Don't commit "temporary" sensitive files**
  - Even temporary files persist in Git history
  - Use `.gitignore` or `/data/` folder

- **Don't email data** to share with collaborators
  - Use SURF FileSender
  - Use institutional secure transfer tools
  - Use approved cloud storage (OneDrive, ResearchDrive)

### Credentials & Secrets

#### DO

- **Use `.env` files locally** (they're Git-ignored)

  ```bash
  # .env (not committed)
  API_KEY=abc123xyz
  DATABASE_URL=postgresql://localhost/mydb
  ```

- **Use GitHub Secrets** for CI/CD
  - Settings → Secrets → Actions
  - Reference in workflows: `${{ secrets.API_KEY }}`

- **Rotate exposed credentials immediately**
  - If a secret is committed, assume it's compromised
  - Generate new credentials
  - Update systems that use them

#### DON'T

- **Don't hardcode secrets** anywhere

  ```python
  # Bad
  api_key = "sk-abc123xyz"

  # Good
  api_key = os.environ.get('API_KEY')
  ```

- **Don't commit example credentials** that look real

  ```yaml
  # Bad - looks too real
  api_key: "sk_live_abc123"

  # Good - obviously fake
  api_key: "YOUR_API_KEY_HERE"
  ```

### Code Quality & Review

#### DO

- **Review changes before committing**

  ```bash
  git diff --staged  # See exactly what you're committing
  ```

- **Write descriptive commit messages**

  ```bash
  # Good
  git commit -m "Add patient anonymization function"

  # Bad
  git commit -m "update"
  ```

- **Keep commits small and focused**
  - Easier to review
  - Easier to revert if needed

- **Update `.gitignore`** for project-specific patterns

  ```gitignore
  # Project-specific
  /outputs/sensitive/
  *_confidential.txt
  ```

#### DON'T

- **Don't bypass hooks** without understanding why

  ```bash
  # Only use if you fully understand the implications
  git commit --no-verify    # Dangerous
  git push --no-verify      # Dangerous
  ```

- **Don't commit generated outputs** with data
  - Use `/results/` for non-sensitive outputs
  - Ignore large or data-containing outputs

- **Don't commit work-in-progress** with `# TODO: remove sensitive data`
  - Clean up before committing
  - Git remembers everything

---

## Incident Response

### What Constitutes an Incident?

Any of the following requires immediate action:

- Sensitive data committed to any branch
- Credentials or API keys in code or history
- PII detected in commit
- Data file in public repository
- Secrets scanner triggered
- Repository made public without approval

### Incident Severity Levels

| Severity | Examples | Response Time |
|----------|----------|---------------|
| **Critical** | Patient data in public repo, active credentials exposed | Immediate (< 1 hour) |
| **High** | Patient data in private repo, revoked credentials exposed | Same day |
| **Medium** | PII detected, no external access | Within 48 hours |
| **Low** | False positive, already cleaned up | Within 1 week |

### Immediate Actions (Do This First)

**If you discover sensitive data in a commit:**

#### Step 1: Stop and Assess (5 minutes)

```bash
# DO NOT PANIC - but act quickly

# Note the following information:
# 1. Repository name: _______________
# 2. What was exposed: _______________
# 3. Which branch: _______________
# 4. When committed: _______________
# 5. Is repo public or private? _______________
# 6. Has anyone else cloned recently? _______________
```

#### Step 2: Contain (10 minutes)

**If repository is public:**

```bash
# Make it private IMMEDIATELY
# GitHub → Settings → Danger Zone → Change visibility → Private
```

**If credentials were exposed:**

```bash
# Rotate/revoke credentials NOW
# - API keys: Regenerate in provider dashboard
# - Passwords: Change immediately
# - SSH keys: Remove from authorized_keys
# - Tokens: Revoke in service settings
```

#### Step 3: Report (15 minutes)

**Do NOT try to fix it yourself first** - Git history rewriting requires coordination.

**Contact security team:**

- **Email:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
- **Subject:** "SECURITY INCIDENT: [Brief Description]"
- **Mark as urgent/high priority**

**Include in your report:**

```bash
Repository: [org/repo-name]
Branch: [main/feature-x]
Exposed content: [patient data / credentials / PII]
File(s): [path/to/file.csv]
Commit hash: [abc123def456]
Committed by: [username]
Date: [YYYY-MM-DD HH:MM]
Repository visibility: [Public / Private]
Already cloned by others: [Yes / No / Unknown]
Credentials rotated: [Yes / No / N/A]
Additional context: [any other relevant information]
```

**Do NOT:**

- Open a public GitHub issue
- Post in public Slack channels
- Email to distribution lists
- Include actual sensitive data in report

#### Step 4: Wait for Guidance (30 minutes - 2 hours)

Security team will respond with:

- Incident severity assessment
- Specific remediation steps
- Timeline and coordination plan

**Do not make additional commits until instructed.**

### Full Remediation Process

Once security team responds, you'll follow these steps (with their guidance):

#### 1. Backup Current State

```bash
# Create a backup branch
git branch backup-before-cleanup

# Push to a secure location if needed
git push origin backup-before-cleanup
```

#### 2. Remove from History

**Option A: BFG Repo-Cleaner (recommended for simple cases)**

```bash
# Install BFG
# macOS: brew install bfg
# Linux: Download from https://rtyley.github.io/bfg-repo-cleaner/

# Clone a fresh mirror
git clone --mirror https://github.com/org/repo.git

# Remove sensitive files
bfg --delete-files '*.csv' repo.git
bfg --delete-files 'sensitive.txt' repo.git

# Clean up
cd repo.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (after approval)
git push --force
```

**Option B: git-filter-repo (recommended for complex cases)**

```bash
# Install git-filter-repo
pip install git-filter-repo

# Remove specific file from all history
git filter-repo --path path/to/sensitive.csv --invert-paths

# Remove files matching pattern
git filter-repo --path-regex '^data/.*\.csv$' --invert-paths

# Force push (after approval)
git push --force
```

#### 3. Verify Cleanup

```bash
# Search for sensitive patterns in entire history
git log --all --full-history --source --pretty=format:'%H %s' -- '*.csv'

# Search file contents in history
git grep -i "sensitive pattern" $(git rev-list --all)

# Should return no results
```

#### 4. Force Push & Notify

**Warning:** Force pushing rewrites history. All collaborators must re-clone.

```bash
# After security team approval
git push --force --all
git push --force --tags

# Delete backup branch (after verification)
git branch -D backup-before-cleanup
git push origin --delete backup-before-cleanup
```

#### 5. Notify Collaborators

**Email template:**

```email
Subject: [URGENT] Repository history rewritten - re-clone required

Repository: org/repo-name

Action required: Please re-clone this repository immediately.

Reason: Sensitive data was removed from Git history for security/compliance.

Steps:
1. Commit and push any local work to a new branch
2. Delete your local repository
3. Clone fresh copy: git clone https://github.com/org/repo.git
4. Cherry-pick your work if needed

Do NOT pull/rebase existing clones - they contain old history.

Questions: Contact [security contact]
```

#### 6. Post-Incident Review

Document the incident:

- What was exposed
- How it happened
- What prevented detection
- How to prevent recurrence
- Updates to processes/training

### False Positives

If security checks block legitimate content:

1. **Verify it's actually a false positive**
   - Is this truly non-sensitive?
   - Could it be misinterpreted as sensitive?

2. **Contact security team** with:
   - What's being blocked
   - Why it's legitimate
   - How to distinguish from real violations

3. **Wait for exception approval**
   - Don't bypass with `--no-verify`
   - Exceptions are added to central config

4. **Document the exception**
   - Add comments explaining why allowed
   - Update project README if needed

---

## Repository Access Control

### Account Security

**Required for all GitHub users:**

- **Enable 2FA** (Two-Factor Authentication)
  - GitHub → Settings → Password and authentication → Enable 2FA
  - Use authenticator app (not SMS)

- **Use strong passwords**
  - Minimum 12 characters
  - Unique to GitHub (use password manager)

- **Review authorized applications regularly**
  - GitHub → Settings → Applications
  - Revoke unused OAuth apps

### Repository Visibility

**Default policy: Private**

- All new repositories must be **private** by default
- Public repositories require security review and approval

**Before making a repository public:**

- [ ] Full Git history reviewed (no sensitive data ever committed)
- [ ] Security scans pass (GitHub Actions all green )
- [ ] No credentials or secrets in code or config
- [ ] README, LICENSE, and documentation complete
- [ ] Code quality meets standards
- [ ] Approved by project lead **and** data steward
- [ ] External collaborators (if any) informed

**Making a repository public:**

1. Run comprehensive security scan

   ```bash
   pre-commit run --all-files
   git log --all --oneline | wc -l  # Check commit count
   ```

2. Request approval via email to security team

3. Wait for confirmation before changing visibility

4. Update documentation with public-facing information

### Collaborator Management

**Adding collaborators:**

- Use **least privilege** principle
  - Read: For reviewers, observers
  - Write: For active contributors
  - Admin: Only for repository owners

- **Review access quarterly**
  - Remove former team members
  - Downgrade unnecessary permissions

- **Use teams** for groups
  - GitHub → Organizations → Teams
  - Easier to manage bulk access

**External collaborators:**

- Require approval from project lead
- Must acknowledge security policy
- Limited to specific repositories
- Review access more frequently (monthly)

### Branch Protection

**Required for production branches (`main`, `master`):**

- Require pull request reviews (minimum 1 reviewer)
- Require status checks to pass: "Org Security Scan"
- Require branches to be up to date before merging
- Require signed commits (recommended)
- Include administrators (no exceptions)
- Do not allow force pushes (except for incidents)
- Do not allow deletions

**Configure:**

```bash
GitHub → Settings → Branches → Add branch protection rule
Branch name pattern: main
[Enable all required checks]
```

---

## Reporting Vulnerabilities

### Security Issues in This Repository

If you discover a vulnerability in **this project**:

1. **Do NOT open a public issue**

2. **Email security team privately:**
   - **To:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
   - **Subject:** "Security Vulnerability Report"
   - **Mark as confidential**

3. **Include:**
   - Description of vulnerability
   - Steps to reproduce
   - Potential impact assessment
   - Suggested fix (if known)

4. **Do NOT:**
   - Include actual sensitive data
   - Exploit the vulnerability
   - Share details publicly before fix

### Security Issues in Dependencies

If security scanners flag vulnerable dependencies:

**For npm packages:**

```bash
npm audit
npm audit fix
```

**For Python packages:**

```bash
pip-audit
# or
safety check
```

**For R packages:**

```R
# No automated scanner - check manually:
# https://github.com/r-lib/pkgdepends
```

**Report high-severity issues:**

- Update dependencies if patches available
- Contact security team if no fix exists
- Document known vulnerabilities in README

### Expected Response Times

| Severity | Initial Response | Status Update | Resolution Target |
|----------|------------------|---------------|-------------------|
| **Critical** | 1 hour | Every 4 hours | 24 hours |
| **High** | 4 hours | Daily | 1 week |
| **Medium** | 1 day | Weekly | 1 month |
| **Low** | 1 week | As needed | Next release |

---

## Compliance & Audit

This security policy supports compliance with:

- **GDPR** (General Data Protection Regulation)
- **HIPAA** (Health Insurance Portability and Accountability Act)
- **WMO** (Dutch Medical Research Involving Human Subjects Act)
- **Amsterdam UMC Data Management Policy**

### Audit Trail

All security-relevant events are logged:

- Pre-commit/pre-push violations (local logs)
- GitHub Actions failures (workflow logs)
- Security alerts (telemetry system)
- Manual exceptions (documented in security repo)

### Regular Reviews

- **Quarterly:** Access permissions review
- **Biannually:** Security policy update
- **Annually:** Full security audit
- **Ad-hoc:** After incidents or major changes

---

## Additional Resources

### Documentation

- **[Security Workflows Guide](docs/security-workflows.md)** - Technical deep dive
- **[Data Handling Best Practices](docs/data-handling.md)** - Safe data workflows
- **[FAQ](docs/faq.md)** - Common questions

### Tools

- **[Pre-commit](https://pre-commit.com/)** - Local hook framework
- **[BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)** - History cleaning
- **[git-filter-repo](https://github.com/newren/git-filter-repo)** - Advanced history rewriting
- **[GitGuardian](https://www.gitguardian.com/)** - Secrets detection

### External Standards

- **[GitHub Security Best Practices](https://docs.github.com/en/code-security)**
- **[OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)**
- **[NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)**

---

## Policy Updates

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.1 | Jan 2026 | Added PII detection, improved incident response |
| 1.0 | 2024 | Initial policy |

**Change Process:**

1. Propose changes via pull request to security team
2. Security team reviews and approves
3. Announce updates to all users
4. Update documentation and training materials

---

## Questions & Support

**Security Questions:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
**Data Management:** Contact your data steward
**Technical Support:** Research Software Management team
**Policy Questions:** Amsterdam UMC Information Security Office

---

**Remember:** Security is everyone's responsibility. When in doubt, ask. It's always better to check than to risk a data breach.

---

_This policy is maintained by Amsterdam UMC Research Software Management in collaboration with Information Security and Data Management teams._
