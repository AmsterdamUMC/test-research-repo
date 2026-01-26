# Research Project Template (Secure & Reproducible)

This repository template helps Amsterdam UMC researchers:

- Organize research code and analysis
- Prevent accidental upload of sensitive data
- Make work reproducible and understandable
- Comply with GDPR and institutional data protection requirements

**This template is specifically designed for healthcare research with patient data, research datasets, and sensitive information.**

---

## Quick Start

1. Click **"Use this template"** on GitHub to create a new repository
2. Create a **private repository** (required for projects with sensitive data)
3. Clone to your local machine
4. **Install pre-commit hooks** (see below - required for all contributors)
5. Replace this README with your project documentation using [`README-template.md`](README-template.md)

---

## Security System Overview

This template includes **four layers of protection** to prevent accidental data leaks:

| Layer | When It Runs | What It Checks | Can Be Bypassed? |
| ------- | -------------- | --------------- | ------------------ |
| **`.gitignore`** | Before `git add` | Blocks tracking of sensitive file types | Yes (with `-f` flag) |
| **Pre-commit hook** | Before `git commit` | Forbidden files, PII, secrets, formatting | Yes (with `--no-verify`) |
| **Pre-push hook** | Before `git push` | Final check before code leaves your machine | Yes (with `--no-verify`) |
| **GitHub Actions** | After `git push` | Server-side validation, blocks PRs | **No** |

Each layer scans for:

- **Forbidden file types** - Data files, medical imaging, credentials
- **Personal information** - Dutch names, addresses, patient IDs
- **Secrets** - API keys, tokens, passwords, private keys

**No single layer is perfect** - together they catch most mistakes. Always review what you're committing.

---

## Required: Install Pre-Commit Hooks

**Every contributor must install these hooks.** They run automatically before commits and pushes.

```bash
# Install pre-commit (one-time setup)
pip install pre-commit

# Enable hooks in your repository (run in project folder)
pre-commit install
pre-commit install --hook-type pre-push
```

### Verify Installation

Test that hooks are working:

```bash
# This should fail
echo "test data" > test.csv
git add test.csv
git commit -m "test"
# Expected: ❌ Commit blocked by pre-commit hook

# Clean up
rm test.csv
```

If the commit succeeds, **the hooks are not installed correctly**. Run the install commands again.

---

## What Gets Blocked?

The security system blocks several categories of files and content:

### Data Files (Never Commit These)

- **Tabular data:** `.csv`, `.tsv`, `.xlsx`, `.xls`, `.ods`
- **Statistical formats:** `.sav`, `.dta`, `.RData`, `.rds`, `.sas7bdat`
- **Binary formats:** `.feather`, `.parquet`, `.pickle`, `.h5`, `.hdf5`
- **Databases:** `.sqlite`, `.db`

### Medical & Research Data

- **Neuroimaging:** `.nii`, `.nii.gz`, `.dcm` (DICOM)
- **Biosignals:** `.edf`, `.bdf`, `.eeg`, `.vhdr`
- **Genomics:** `.fastq`, `.bam`, `.vcf`, `.bed`

### Personal Information

The system actively scans for:

- Dutch names and addresses
- Patient identification numbers
- BSN (Burgerservicenummer)
- Medical record numbers

### Secrets & Credentials

Detects and blocks:

- API keys (GitHub, AWS, Stripe, SendGrid, Slack, etc.)
- OAuth tokens and JWT tokens
- Database passwords and connection strings
- Private SSH keys and certificates
- Generic secrets with high entropy

### Other Blocked Files

- Archives: `.zip`, `.tar.gz`, `.rar` (may contain data)
- Large media files: `.mp4`, `.avi`, `.mov`
- Most JSON/XML files (exceptions for configuration)

**See [`.gitignore`](.gitignore) and [`gitleaks.toml`](gitleaks.toml) for complete lists.**

---

## Template Contents

| File/Folder | Purpose |
| ------------- | --------- |
| `.github/workflows/` | Automated security checks on every push |
| `.pre-commit-config.yaml` | Local security hooks configuration |
| `.gitignore` | Prevents tracking sensitive file types |
| `gitleaks.toml` | Secrets detection configuration |
| `CODEOWNERS` | Defines code reviewers |
| `CITATION.cff` | Machine-readable citation information |
| `data/` | **Local-only** folder for data files (blocked by Git) |
| `docs/` | Guides on security, data handling, and workflows |
| `README-template.md` | Template for your project's README |
| `SECURITY.md` | Detailed security policy and incident response |
| `CONTRIBUTING.md` | Guidelines for contributors |
| `CODE_OF_CONDUCT.md` | Community standards |

---

## Working with Data

### Safe Data Storage

```bash
# Store data in the /data folder - it's excluded from Git
project/
├── data/           # Safe - blocked by .gitignore
│   ├── raw/
│   └── processed/
├── scripts/        # Commit your analysis code here
└── results/        # Commit figures and non-sensitive outputs
```

### Never Do This

```bash
# Don't put data anywhere else - it might get committed
project/
├── analysis.csv    # Will be committed!
├── scripts/
│   └── temp.xlsx   # Will be committed!
```

### Document Your Data

Update `/data/README.md` to describe:

- Where data came from
- File structure expected by scripts
- How to access secure storage (myDRE, institutional drives)

**Do not include actual file paths or credentials in documentation.**

---

## First Steps After Creating Your Repository

- [ ] Install pre-commit hooks (see above)
- [ ] Test that hooks work (try committing a `.csv` file)
- [ ] Replace this README with [`README-template.md`](README-template.md)
- [ ] Update `CITATION.cff` with your project details
- [ ] Add collaborators (Settings → Collaborators)
- [ ] Review and customize `.gitignore` for project-specific needs
- [ ] Read [`SECURITY.md`](SECURITY.md) for detailed security policy

---

## Help & Documentation

### For Users

- **[Overview](docs/overview.md)** - What this template is for
- **[Data Handling](docs/data-handling.md)** - How to work safely with data
- **[Security Workflows](docs/security-workflows.md)** - How the protection layers work
- **[FAQ](docs/faq.md)** - Common questions answered

### For Contributors

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute safely
- **[SECURITY.md](SECURITY.md)** - Complete security policy

---

## ⚠️ Accidentally Committed Sensitive Data?

**Do NOT panic, but act immediately:**

1. **Stop** - Don't try to fix it yourself
2. **Report** - Contact [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl) immediately
3. **Do NOT** open a public GitHub issue
4. **Include:** Repository name, what was exposed, when committed

Git keeps full history - deleting a file doesn't remove it. We need to rewrite history, which requires coordination.

**See [SECURITY.md](SECURITY.md) for detailed incident response procedures.**

---

## Before Making a Repository Public

Repositories should start **private by default**. Only make public after:

- [ ] Security scans pass (no red ❌ in GitHub Actions)
- [ ] Full Git history reviewed for sensitive data
- [ ] No credentials or API keys in code or history
- [ ] README, LICENSE, and documentation complete
- [ ] Approved by project lead and data steward

---

## Support

**Technical questions:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
**Data management:** Contact your data steward
**Security incidents:** See [SECURITY.md](SECURITY.md)

---

## License

This template is provided under the MIT License. See [LICENSE](LICENSE) for details.

---

_This template supports responsible, open, and reproducible research at Amsterdam UMC._
