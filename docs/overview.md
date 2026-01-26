# Project Template Overview

**What This Template Does**  
This GitHub repository template helps Amsterdam UMC researchers work safely with code and data while preventing accidental data leaks.

---

## Why Use This Template?

Research code often lives alongside sensitive data—patient records, experimental results, confidential information. It's easy to accidentally commit a CSV file or hardcode a password. One `git push` later, and that data is on GitHub servers, potentially forever.

This template prevents those accidents with automated checks that run:
- Before you commit (on your computer)
- Before you push (on your computer)  
- When you push (on GitHub servers)
- When you open a pull request (on GitHub servers)

Think of it as four safety nets, working together.

---

## What You Get

When you use this template, your repository includes:

### Security Infrastructure

**`.gitignore`** - Tells Git to ignore common data files
- CSV, Excel, SPSS, R data files
- Medical imaging, genomics data
- Credentials and API keys
- See the full list in the file itself

**`.pre-commit-config.yaml`** - Automated checks before commits
- Blocks forbidden file types
- Scans for Dutch names and addresses
- Checks for patient ID patterns
- Validates code quality

**`.github/workflows/security-check.yml`** - Server-side validation
- Runs on every push
- Cannot be bypassed
- Alerts security team if violations found
- Blocks pull requests with sensitive data

### Project Structure

**`/data/`** - Local-only folder for your data files
- Blocked from Git tracking
- Safe place for CSVs, spreadsheets, etc.
- Only the README is tracked

**`/scripts/`** - Your analysis code goes here
- R, Python, MATLAB, whatever you use
- This DOES get committed to Git
- Organize however makes sense for your project

**`/results/`** - Non-sensitive outputs
- Aggregated statistics
- Figures and plots
- Model summaries
- Only commit if data-free

**`/docs/`** - Documentation and guides
- How the security system works
- Best practices for data handling
- FAQ for common questions

### Documentation Files

**`README-template.md`** - Starter template for your project
- Replace the main README with this
- Fill in your project details
- Explains what your research does

**`SECURITY.md`** - Complete security policy
- What files are blocked and why
- What to do if you commit sensitive data
- How to report security issues

**`CONTRIBUTING.md`** - Guidelines for contributors
- How to work safely on this project
- Code review practices
- Reproducibility standards

**`CODE_OF_CONDUCT.md`** - Community standards
- Expected behavior
- How to report issues

**`CITATION.cff`** - Machine-readable citation
- How others should cite your work
- Automatically read by GitHub

---

## How It Protects You

### Layer 1: `.gitignore` (Passive)

Files matching these patterns are silently ignored:
```
*.csv
*.xlsx
*.RData
.env
```

**Strength:** Weak - can be overridden with `git add -f`  
**Purpose:** Convenience, prevents accidental staging

### Layer 2: Pre-Commit Hook (Active)

Before each commit, scans staged files for:
- Forbidden file types (from central rules)
- Dutch personal information (names, addresses)
- Patient IDs (7-digit patterns)
- Code quality issues

**Strength:** Strong - requires `--no-verify` to bypass  
**Purpose:** Catch mistakes before they're committed

### Layer 3: Pre-Push Hook (Active)

Before each push, re-scans ALL commits being pushed:
- Checks everything, not just new files
- Catches commits made before hooks installed
- Downloads latest security rules

**Strength:** Strong - requires `--no-verify` to bypass  
**Purpose:** Final check before data leaves your computer

### Layer 4: GitHub Actions (Mandatory)

On GitHub's servers, validates every push:
- Cannot be bypassed
- Blocks pull requests if violations found
- Sends alerts to security team
- Creates tracking issues

**Strength:** Absolute - no way around it  
**Purpose:** Safety net when local checks fail

---

## How to Use This Template

### Step 1: Create Your Repository

1. Go to https://github.com/amsterdamumc/repo-template-secure
2. Click "Use this template" → "Create a new repository"
3. Choose **Private** visibility (always start private!)
4. Give it a meaningful name: `project-name-analysis`

### Step 2: Clone and Set Up

```bash
# Clone your new repository
git clone https://github.com/amsterdamumc/your-project.git
cd your-project

# Install pre-commit
pip install pre-commit

# Enable the hooks (REQUIRED!)
pre-commit install
pre-commit install --hook-type pre-push
```

### Step 3: Test That It Works

```bash
# Try to commit a CSV (should fail!)
echo "test,data" > test.csv
git add test.csv
git commit -m "test"

# Expected: ❌ Hook blocks the commit

# Clean up
rm test.csv
git reset
```

If the commit succeeded, **hooks aren't installed correctly**. Go back to Step 2.

### Step 4: Customize for Your Project

1. **Replace README.md**
   - Copy `README-template.md` to `README.md`
   - Fill in your project details
   - Keep the template somewhere for reference

2. **Update CITATION.cff**
   - Add your name and project details
   - Specify the license
   - Add DOI if you have one

3. **Customize `.gitignore`** (if needed)
   - Add project-specific patterns
   - Don't remove the security patterns!

4. **Document your data**
   - Edit `/data/README.md`
   - Explain where data comes from
   - Don't include actual paths or credentials

### Step 5: Start Working

```bash
# Put data files here (Git-ignored)
data/
├── raw/patients.csv
└── processed/cleaned.xlsx

# Put code here (tracked by Git)
scripts/
├── 01_import.R
├── 02_clean.R
└── 03_analyze.R

# Commit your code
git add scripts/
git commit -m "Add data import script"
git push
```

---

## You Don't Need to Be an Expert

This template is designed for researchers, not software engineers. You don't need to understand how pre-commit works, or what GitHub Actions are, or how the security scanning works.

**You just need to know:**

1. **Data goes in `/data/`** - That folder is safe, Git ignores it
2. **Code goes in `/scripts/`** - This gets tracked by Git
3. **If hooks block something** - Read the error message, it will tell you what's wrong
4. **If you're unsure** - Ask! See [FAQ](faq.md) or contact [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)

The system handles the complexity. You focus on your research.

---

## Common Questions

**Q: Will this slow down my work?**  
A: The first time hooks run takes ~30 seconds (downloading rules). After that, it's 1-5 seconds per commit. Most of your time is spent writing code, not committing it.

**Q: What if I need to commit a CSV?**  
A: You probably don't—most CSVs belong in `/data/`. If you truly need an exception (e.g., a public reference dataset), contact the security team for approval.

**Q: Can I turn off the security checks?**  
A: The local hooks (layers 1-3) can be bypassed with `--no-verify`, but the GitHub Actions (layer 4) cannot. Bypassing is strongly discouraged and will trigger alerts.

**Q: What happens if I accidentally commit sensitive data?**  
A: Don't panic! Contact [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl) immediately with subject "SECURITY INCIDENT". We'll help you clean up Git history. See [SECURITY.md](../SECURITY.md#incident-response) for details.

**Q: This seems complicated...**  
A: It's simpler than it looks! The template does the heavy lifting. You just:
   - Put data in `/data/`
   - Put code in `/scripts/`  
   - Commit and push normally
   - Let the system catch mistakes

**More questions?** See the [FAQ](faq.md) or [Security Workflows](security-workflows.md) guide.

---

## What This Template Doesn't Do

This template helps with **GitHub security**. It doesn't handle:

- **Data storage** - You still need myDRE, network drives, etc.
- **Data sharing** - Use SURF FileSender or institutional tools
- **Access control** - Set repository permissions appropriately
- **Backup** - Keep backups of your work separate from Git
- **Computing environment** - Use your own workstation, cluster, or cloud

Think of this as **one layer** in your research data management strategy, focused specifically on preventing accidental data leaks via Git.

---

## Getting Started Checklist

Before you begin your project:

- [ ] Created repository from template
- [ ] Cloned to local machine
- [ ] Installed pre-commit hooks
- [ ] Tested that hooks work (try committing a CSV)
- [ ] Replaced README with your project details
- [ ] Updated CITATION.cff
- [ ] Read [data-handling.md](data-handling.md)
- [ ] Know where your data is stored (myDRE, network drive, etc.)
- [ ] Know how to contact security team if needed

---

## Support & Resources

**Documentation:**
- [Data Handling Guide](data-handling.md) - Where to put files, how to work safely
- [Security Workflows](security-workflows.md) - Technical details of how it works
- [FAQ](faq.md) - Answers to common questions
- [SECURITY.md](../SECURITY.md) - Complete security policy

**Get Help:**
- **Technical issues:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
- **Data management questions:** Your project's data steward
- **Security incidents:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl) (mark URGENT)

**Related Systems:**
- **Security rules:** https://github.com/amsterdamumc/org-security-workflows
- **Telemetry system:** https://github.com/amsterdamumc/security-telemetry
- **Organization scanner:** https://github.com/amsterdamumc/org-security-scanner

---

## Remember

This template exists to **help you work confidently**, not to restrict you. The goal is simple: make it easy to do the right thing, and hard to accidentally do the wrong thing.

Research is hard enough without worrying about data breaches. Let the system handle the security, so you can focus on science.

**Questions?** Just ask. We're here to help.

---

_This template is maintained by Amsterdam UMC Research Software Management to support responsible, open, and reproducible research._

**Version:** 2.0  
**Last Updated:** January 2026  
**Maintainer:** Bauke van der Velde ([b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl))