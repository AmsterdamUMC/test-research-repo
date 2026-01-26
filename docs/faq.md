# Frequently Asked Questions (FAQ)

Quick answers to common questions about using this secure research template.

---

## Setup & Installation

### Q: Do I really need to install pre-commit hooks?

**A: Yes, absolutely.** Pre-commit hooks are your first line of defense against accidentally committing sensitive data. They catch mistakes before code ever leaves your computer.

Without hooks installed:
- You have no local protection
- You rely entirely on GitHub Actions (which runs after upload)
- You're one `git push` away from a data breach

Installation takes 2 minutes:
```bash
pip install pre-commit
pre-commit install
pre-commit install --hook-type pre-push
```

### Q: I installed pre-commit but it's not running. What's wrong?

**Check these common issues:**

1. **Are you in the right directory?**
   ```bash
   # Must be in repository root
   pwd  # Should show your project folder
   ls .git  # Should exist
   ```

2. **Are hooks actually installed?**
   ```bash
   ls .git/hooks/pre-commit  # Should exist
   ls .git/hooks/pre-push    # Should exist
   ```

3. **Try reinstalling:**
   ```bash
   pre-commit uninstall
   pre-commit install
   pre-commit install --hook-type pre-push
   ```

4. **Test manually:**
   ```bash
   pre-commit run --all-files
   ```

If still not working, contact [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl).

### Q: Can I use this template without installing anything?

**No.** The `.gitignore` file provides minimal protection, but it's easily bypassed. GitHub Actions provide the final safety net, but they run **after** you've already pushed code.

**You need local hooks** to prevent sensitive data from ever leaving your machine.

### Q: I use Windows. Will this work?

**Yes.** Pre-commit works on Windows, macOS, and Linux.

**Windows users should:**
- Use Git Bash, PowerShell, or Windows Terminal
- Ensure Python is installed: `python --version`
- Install pre-commit: `pip install pre-commit`

If you get "command not found" errors, check that Python's Scripts folder is in your PATH.

---

## Working with Data

### Q: Why can't I upload my `.csv` file?

**A: CSV files commonly contain patient data, research datasets, or other sensitive information.** Even "anonymized" CSV files may contain re-identification risks.

**What to do instead:**

1. **Keep data in the `/data/` folder**
   ```bash
   project/
   ├── data/           # Git-ignored, safe for CSV files
   │   └── analysis.csv
   ```

2. **Document your data** in `/data/README.md`
   - Describe what the data contains (without including actual data)
   - Explain how to access it from secure storage
   - Include instructions for reproducing the dataset

3. **Use placeholder data** in examples
   ```python
   # Good - clearly synthetic
   example = pd.DataFrame({
       'patient_id': ['PATIENT_001', 'PATIENT_002'],
       'measurement': [120, 130]
   })
   ```

### Q: What if my CSV doesn't contain sensitive data?

**Contact the security team** for an exception. Examples of legitimate CSVs:

- Public datasets (with citation/license)
- Lookup tables (country codes, reference values)
- Configuration files (non-sensitive settings)
- Test fixtures (clearly fake data)

**Do NOT bypass the security checks yourself.** Exceptions must be reviewed and documented.

### Q: Where should I store my data files?

**Local storage hierarchy:**

```bash
project/
├── data/                    # BEST - Git-ignored, for sensitive data
│   ├── raw/
│   ├── processed/
│   └── README.md           # Document what goes here
├── scripts/                 # GOOD - Commit your code here
│   └── analysis.R
├── results/                 # OKAY - Non-sensitive outputs only
│   ├── figures/
│   └── tables/
└── temp.csv                 # BAD - Will be committed!
```

**Remote storage options:**

- myDRE - For sensitive patient data
- SURF Research Cloud - For research datasets
- Institutional network drives - With proper access controls
- OneDrive/SharePoint - Amsterdam UMC approved
- Personal Dropbox/Google Drive - Not allowed for patient data
- Email - Never for data files

### Q: Can I commit a small test CSV?

**No.** Even small test files:
- Set a bad precedent
- May accidentally contain real data later
- Teach bad habits to other team members
- Trigger security alerts

**Instead:**
```python
# Generate test data in code
test_data = pd.DataFrame({
    'id': range(10),
    'value': np.random.rand(10)
})

# Or use Python's io.StringIO
from io import StringIO
test_csv = StringIO("id,value\n1,0.5\n2,0.8")
df = pd.read_csv(test_csv)
```

### Q: My analysis creates output files. Should I commit them?

**Depends on the content:**

| Output Type | Commit? | Storage Location |
|-------------|---------|------------------|
| Summary statistics (aggregated) | Yes | `/results/` |
| Figures/plots (no individual data) | Yes | `/results/figures/` |
| Model coefficients | Yes | `/results/models/` |
| P-values, confidence intervals | Yes | `/results/statistics/` |
| Large model files (>100MB) | ❌ No | Use Git LFS or exclude |
| Individual predictions | ❌ No | Keep in `/data/` |
| Cross-validation results (per subject) | ❌ No | Keep in `/data/` |

**Rule of thumb:** If someone could reverse-engineer individual data points from your output, don't commit it.

---

## Git & Version Control

### Q: What happens if I accidentally commit sensitive data?

**Don't panic, but act quickly:**

1. **Stop immediately** - Don't make more commits
2. **Assess severity:**
   - Is the repository public or private?
   - What exactly was exposed?
   - Did anyone else pull the commits?

3. **Report to security team:**
   - Email: [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
   - Include: repo name, file, commit hash, timestamp

4. **Follow remediation guidance**
   - Security team will help clean Git history
   - All collaborators must re-clone

**See [SECURITY.md](../SECURITY.md#incident-response) for detailed steps.**

### Q: Can I just delete the file and commit again?

**No.** Deleting a file doesn't remove it from Git history. Anyone can still see it:

```bash
# This doesn't work - file is still in history
git rm sensitive.csv
git commit -m "remove sensitive file"

# People can still access it
git checkout HEAD~1 -- sensitive.csv  # File is back!
```

**You need to rewrite history** using tools like BFG or git-filter-repo. This requires coordination with the security team.

### Q: What if I need to bypass the pre-commit hook?

**You almost never should.** Bypassing security checks defeats their purpose.

**Legitimate reasons to bypass:**
- False positive you've reported and are waiting for exception
- Urgent hotfix (with security team approval)
- Technical issue with hooks (temporarily, while troubleshooting)

**How to bypass (use with extreme caution):**
```bash
git commit --no-verify -m "message"
git push --no-verify
```

**Remember:** GitHub Actions still run and will block you. Telemetry will alert the security team.

### Q: How do I update my pre-commit hooks?

**Automatic updates:**
```bash
# Get latest hook versions
pre-commit autoupdate

# Run to verify they work
pre-commit run --all-files
```

**Manual version update:**

Edit `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/AmsterdamUMC/org-security-workflows
    rev: v0.2.21  # ← Update this version number
```

Then:
```bash
pre-commit install --install-hooks
pre-commit run --all-files
```

### Q: The hooks are running very slowly. Is this normal?

**First run is slow** because hooks need to:
- Download security rules
- Set up Python environments
- Scan all files

**Subsequent runs are fast** because:
- Hooks only check changed files
- Environments are cached
- Rules are downloaded once

**Tips for faster hooks:**
- Commit smaller changes more frequently
- Use `.gitignore` to exclude unnecessary files
- Run `pre-commit gc` to clean old environments

**If still slow:**
```bash
# Run in parallel (if available)
pre-commit run --all-files --hook-stage push --show-diff-on-failure
```

---

## Security & Privacy

### Q: Why does the scanner flag my code that processes patient data?

**This is intentional.** The PII scanner looks for patterns that indicate sensitive data, including:
- Variable names like `patient_name`, `bsn_number`
- Dutch name patterns in strings
- Address-like text
- Medical record number formats

**This is a feature, not a bug.** Code that processes PII should be:
1. Carefully reviewed
2. Well-documented
3. Minimized to only what's necessary

**If your code is legitimate:**
- Add clear comments explaining what you're doing
- Use obviously fake examples in documentation
- Contact security team if needed for exception

### Q: What's the difference between `.gitignore` and pre-commit hooks?

**`.gitignore`:**
- **Passive** protection
- Tells Git to ignore files
- Easily bypassed with `-f` flag
- No warnings or errors
- Best for: Keeping your working directory clean

**Pre-commit hooks:**
- **Active** protection
- Actively scans and blocks
- Requires `--no-verify` to bypass
- Shows clear error messages
- Best for: Catching mistakes before they're committed

**You need both:**
- `.gitignore` prevents accidental `git add`
- Pre-commit catches forced adds or already-tracked files

### Q: Can the security team see my code?

**Repository visibility:**
- **Private repos:** Only people you add as collaborators
- **Public repos:** Anyone on the internet

**Security scanning:**
- Hooks run locally on your computer
- Only metadata sent to telemetry (file types, not contents)
- GitHub Actions logs may contain file names (not contents)

**Security incidents:**
- If you commit sensitive data, security team needs to review
- Only to determine severity and remediation
- Handled confidentially

### Q: What if I need to share data with a collaborator?

**Never via GitHub.** Use approved data sharing methods:

**Internal collaborators (Amsterdam UMC):**
- myDRE shared workspaces
- Institutional network drives
- OneDrive/SharePoint (for appropriate data types)
- SURF Research Cloud

**External collaborators:**
- SURF FileSender (up to 1TB, auto-deletes)
- Data transfer agreements via data steward
- Secure FTP (if institutionally approved)
- Email attachments
- Personal cloud storage
- USB drives (without encryption)

**Code-only collaboration:**
- GitHub (no data files)
- Pull requests for review
- Issues for discussion

---

## Secrets & Credentials

### Q: What secrets does gitleaks detect?

**Gitleaks scans for hardcoded credentials including:**

**Service-specific tokens:**
- GitHub personal access tokens (`ghp_...`)
- AWS access keys (`AKIA...`)
- Slack bot tokens (`xoxb-...`)
- Stripe API keys (`sk_live_...`)
- SendGrid API keys (`SG....`)
- And 100+ other services

**Generic patterns:**
- API keys with high entropy
- JWT tokens
- OAuth tokens
- Database connection strings with passwords
- Private SSH keys

**What it doesn't catch:**
- Very generic passwords (too many false positives)
- Low-entropy strings
- Well-known test keys (AWS documentation examples)

### Q: Gitleaks is blocking my code. What do I do?

**If it's a real secret:**
1. Remove it from the code
2. Store in `.env` file (Git-ignored)
3. Use environment variables in code:
   ```python
   import os
   api_key = os.environ.get('API_KEY')
   ```

**If it's a false positive:**
- Example code: Make it obviously fake (`API_KEY="YOUR_KEY_HERE"`)
- Documentation: Use placeholders or add file to allowlist in `gitleaks.toml`
- Test fixtures: Use clearly synthetic values

### Q: How do I store secrets properly?

**Local development:**
```bash
# Create .env file (Git-ignored)
echo "API_KEY=your_actual_key" > .env
echo "DB_PASSWORD=your_password" >> .env

# Load in code
# Python:
from dotenv import load_dotenv
load_dotenv()

# R:
library(dotenv)
load_dot_env()
```

**GitHub Actions:**
- Settings → Secrets → Actions
- Reference as `${{ secrets.API_KEY }}`

**Production:**
- Use environment variables
- Use secret management services (Azure Key Vault, AWS Secrets Manager)
- Never hardcode in code

### Q: I accidentally committed a secret. What now?

**Act immediately:**
1. **Rotate the secret** - Generate new key/password
2. **Contact security:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
3. **Don't just delete** - Git history remembers everything

See [SECURITY.md](../SECURITY.md#incident-response) for full remediation steps.

---

## Specific File Types

### Q: Can I commit JSON files?

**It depends.** JSON files are blocked by default because they often contain:
- Configuration with credentials
- API responses with patient data
- Serialized database records

**Exceptions allowed:**
- Package manifests (`package.json`, `package-lock.json`)
- Configuration templates (no secrets)
- Schema definitions
- Static reference data (public)

**Request exception if needed.**

### Q: What about Jupyter notebooks?

**Notebooks are allowed** but be extremely careful:

**Clean notebooks before committing:**
```bash
# Install nbstripout
pip install nbstripout

# Strip outputs from all notebooks
nbstripout notebook.ipynb

# Or configure it to run automatically
nbstripout --install
```

**Why clean outputs?**
- Notebook outputs may contain data
- Plots may show individual patients
- Error messages may reveal file paths

**Best practice:**
```python
# At start of notebook
# This notebook works with data in /data/ folder
# Data is not included in repository
# See /data/README.md for access instructions
```

### Q: Can I commit `.RData` or `.rds` files?

**No.** These are R's binary data formats and are blocked because they:
- Contain actual data (not code)
- Can include entire datasets
- Cannot be reviewed in text form

**What to do instead:**
- Keep `.RData` files in `/data/`
- Use `renv` for package management (not data)
- Commit scripts that generate results, not results themselves

**For reproducibility:**
```R
# Save script to generate data, not data itself
# data_preparation.R
source("functions.R")
processed_data <- prepare_data(raw_data)
# Users run this script with their own data copy
```

### Q: Why are ZIP files blocked?

**ZIP files can contain anything:**
- Datasets you forgot about
- Old versions with sensitive data
- Cached credentials
- Backup files

**Instead of ZIPs:**
- Commit individual code files
- Use Git's built-in compression
- For large resources, use Git LFS
- For data archives, use institutional storage

---

## Workflow & Collaboration

### Q: How do I onboard a new team member?

**Checklist for new collaborators:**

1. **Grant repository access**
   - Settings → Collaborators → Add
   - Use least privilege (usually "Write")

2. **Share onboarding materials**
   - This FAQ
   - [SECURITY.md](../SECURITY.md)
   - [Security Workflows](security-workflows.md)

3. **Ensure they install hooks**
   ```bash
   pip install pre-commit
   pre-commit install
   pre-commit install --hook-type pre-push
   ```

4. **Test their setup**
   ```bash
   echo "test" > test.csv
   git add test.csv
   git commit -m "test"  # Should fail
   rm test.csv
   ```

5. **Review project-specific practices**
   - Where data is stored
   - How to access secure environments
   - Team communication channels

### Q: What's the difference between a public and private repository?

**Private repository:**
- Only invited collaborators can see it
- Safer for work-in-progress
- Required for any sensitive data (past, present, or future)
- Can be made public later (after review)

**Public repository:**
- Anyone on the internet can see it
- All history is visible forever
- Good for open science, after cleaning
- Cannot be made private again (easily)

**Default: Start private.** Only go public after security review.

### Q: Can I make my repository public if it never had sensitive data?

**Maybe.** Even if you never committed sensitive data, you need to verify:

**Check before making public:**
- [ ] No credentials in history (search for API keys, passwords)
- [ ] No file paths revealing institutional structure
- [ ] No comments with sensitive information
- [ ] No personal email addresses (unless intended)
- [ ] README is polished and informative
- [ ] LICENSE file is appropriate
- [ ] Security scans pass (GitHub Actions all green)
- [ ] Project lead and data steward approve

**How to check history:**
```bash
# Search for potential secrets
git log -S "password" --all
git log -S "api_key" --all
git log -S "@amsterdamumc.nl" --all

# List all files ever committed
git log --all --pretty=format: --name-only | sort -u
```

### Q: Our team uses GitLab/Bitbucket. Can we use this template?

**Yes, with modifications:**

The security concepts apply universally, but:
- `.github/workflows/` is GitHub-specific → Adapt to GitLab CI or Bitbucket Pipelines
- Pre-commit hooks work the same
- `.gitignore` works the same
- Some integrations may differ

**Contact security team** for guidance on non-GitHub platforms.

---

## Troubleshooting

### Q: "pre-commit: command not found" error

**Cause:** Pre-commit is not installed or not in PATH.

**Solutions:**

```bash
# Try installing with pip
pip install pre-commit

# Or pip3
pip3 install pre-commit

# Or with conda
conda install -c conda-forge pre-commit

# Verify installation
which pre-commit
pre-commit --version
```

**If still not found:**
```bash
# Add Python scripts to PATH (Linux/Mac)
export PATH="$HOME/.local/bin:$PATH"

# Or on Windows (PowerShell)
$env:Path += ";$HOME\AppData\Local\Programs\Python\Python39\Scripts"
```

### Q: Hooks run but don't block commits

**Possible causes:**

1. **Hooks installed in wrong repository**
   ```bash
   # Verify you're in project root
   pwd
   ls .git  # Should exist
   ```

2. **Hooks not executable** (Linux/Mac only)
   ```bash
   chmod +x .git/hooks/pre-commit
   chmod +x .git/hooks/pre-push
   ```

3. **Using wrong Git command**
   ```bash
   # These bypass hooks:
   git commit --no-verify  #
   git push --no-verify    #
   ```

4. **Hooks configuration invalid**
   ```bash
   # Test hooks manually
   pre-commit run --all-files
   ```

### Q: "Failed to download hooks" error

**Cause:** Network connectivity or GitHub access issue.

**Solutions:**

```bash
# Update pre-commit
pip install --upgrade pre-commit

# Clear hook cache and try again
pre-commit clean
pre-commit install --install-hooks

# Try running with verbose output
pre-commit run --all-files --verbose
```

**If behind proxy:** Configure Git proxy settings.

### Q: GitHub Actions fail but local hooks pass

**Possible causes:**

1. **Different versions**
   - Local: v0.2.20
   - GitHub: v0.2.21

   **Solution:** Update `.pre-commit-config.yaml` to match

2. **Files not tracked locally**
   ```bash
   # Check what's actually being pushed
   git log origin/main..HEAD --name-only
   ```

3. **Different file contents**
   - Maybe file was modified after commit?

   **Solution:** Run `git diff origin/main` to check

4. **Cache issues**
   ```bash
   # Force fresh hook download
   pre-commit clean
   pre-commit install --install-hooks
   pre-commit run --all-files
   ```

---

## Getting Help

### Q: Who do I contact for different issues?

**Technical problems (hooks, Git, setup):**
- [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
- Include: error message, what you tried, your OS

**Security incidents (committed sensitive data):**
- [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
- Mark as URGENT
- See [SECURITY.md](../SECURITY.md#incident-response)

**Data management questions:**
- Your project's data steward
- Amsterdam UMC Data Management team

**Policy questions:**
- Amsterdam UMC Information Security Office
- Research Software Management

### Q: Can I suggest improvements to this template?

**Yes!** We welcome feedback:

- **Bug reports:** Open issue in template repository
- **Security concerns:** Email security team directly
- **Feature requests:** Discuss with Research Software Management
- **Documentation improvements:** Submit pull request

**Before suggesting changes:**
- Check if it's already been discussed
- Consider security implications
- Verify it helps the broader community

---

## Quick Reference

### Essential Commands

```bash
# Install pre-commit
pip install pre-commit

# Enable hooks
pre-commit install
pre-commit install --hook-type pre-push

# Test setup
echo "test" > test.csv
git add test.csv
git commit -m "test"  # Should fail
rm test.csv

# Update hooks
pre-commit autoupdate

# Run hooks manually
pre-commit run --all-files

# Check what you're about to commit
git diff --staged
```

### File Storage Guide

```bash
/data/          # Sensitive data (Git-ignored)
/scripts/       # Your code (commit this)
/results/       # Non-sensitive outputs
/docs/          # Documentation
Anywhere else   # Risk of accidental commit
```

### When to Contact Security

- Committed sensitive data (URGENT)
- Need exception for blocked file type
- Questions about what's allowed
-  Setting up new projects
-  Before making repository public
-  Hooks not working as expected

---

**Still have questions?** Contact [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)

---

_This FAQ is maintained by Amsterdam UMC Research Software Management. Last updated: January 2026_
