# Working with Data in This Project

This guide explains how to safely handle research data when using this GitHub repository template.

---

## The Golden Rule

**Data files never go in Git. Ever.**

Even if the data is "anonymized," even if it's "just a small test file," even if you're "going to delete it later." Git remembers everything forever, and removing data from Git history is complex and requires coordination.

---

## Where Your Data Should Live

### Safe: The `/data/` Folder

```
your-project/
├── data/              # ← PUT ALL DATA HERE
│   ├── raw/
│   │   └── patients.csv      # Safe - Git ignores this
│   ├── processed/
│   │   └── cleaned.xlsx      # Safe - Git ignores this
│   └── README.md             # Only this file is tracked by Git
```

The `/data/` folder is:
- **Ignored by Git** - Files here won't be committed
- **Local only** - Stays on your computer
- **Protected by all four security layers** - Even if you try to force-add files

### Dangerous: Anywhere Else

```
your-project/
├── analysis.csv       # ⚠️ WILL BE COMMITTED!
├── scripts/
│   └── temp.xlsx      # ⚠️ WILL BE COMMITTED!
└── results/
    └── raw_data.RData # ⚠️ WILL BE COMMITTED!
```

---

## What to Do Instead

### For Data Storage

**On your local machine:**
```
/data/                 # Local data folder (Git-ignored)
├── raw/              # Original data (never modify)
├── processed/        # Cleaned/transformed data
└── outputs/          # Analysis results (if they contain data)
```

**On secure servers:**
- **myDRE** - Medical Research Data Environment (patient data)
- **SURF Research Cloud** - Research computing platform
- **Amsterdam UMC network drives** - Institutional storage
- **OneDrive/SharePoint** - For appropriate data types (check with data steward)

### For Documentation

In `/data/README.md`, document:

```markdown
# Data Directory

## Data Sources

- **Raw data:** Downloaded from myDRE workspace `project-xyz` on 2024-01-15
- **Study period:** January 2023 - December 2023
- **Number of subjects:** 150 patients

## File Structure

Expected files:
- `raw/patient_data.csv` - Main patient records
- `raw/lab_results.xlsx` - Laboratory measurements
- `processed/merged_data.RData` - Combined dataset after cleaning

## Access Instructions

1. Log into myDRE: https://mydre.amsterdamumc.nl
2. Navigate to Workspace: `cardiology-outcomes-2023`
3. Download files from `/data/export/` folder
4. Place in this `/data/raw/` directory

## Notes

- Patient IDs are 7-digit numbers
- Missing values coded as -999
- Dates in DD-MM-YYYY format
```

**Important:** Don't include actual file paths, credentials, or patient identifiers in the README.

---

## What Gets Blocked

The security system blocks these file types automatically:

### Data Files
- Tabular: `.csv`, `.tsv`, `.xlsx`, `.xls`, `.ods`
- Statistical: `.sav`, `.dta`, `.RData`, `.rds`, `.sas7bdat`
- Binary: `.feather`, `.parquet`, `.pickle`, `.h5`
- Databases: `.sqlite`, `.db`

### Medical/Research Data
- Imaging: `.nii`, `.dcm` (brain scans, DICOM)
- Biosignals: `.edf`, `.bdf` (EEG, ECG)
- Genomics: `.fastq`, `.bam`, `.vcf`

### Personal Information
The system scans for:
- Dutch names (first names + surnames)
- Dutch addresses (street names + house numbers)
- Patient ID patterns (7-digit numbers)
- BSN (Burgerservicenummer)

**See [SECURITY.md](../SECURITY.md#forbidden-content) for the complete list.**

---

## Working with Results

### What Can Be Committed

✅ **Aggregated results** (no individual data):
```R
# Summary statistics (OK to commit)
summary_stats <- data.frame(
  group = c("Treatment", "Control"),
  mean_age = c(45.2, 43.8),
  n = c(75, 75)
)
write.csv(summary_stats, "results/summary.csv")
```

✅ **Figures and plots** (without individual data points):
```R
# Group-level plot (OK to commit)
ggplot(summary_stats, aes(x = group, y = mean_age)) +
  geom_bar(stat = "identity")
ggsave("results/figures/mean_age_by_group.png")
```

✅ **Model coefficients**:
```R
# Regression output (OK to commit)
model_summary <- summary(lm(outcome ~ treatment + age))
saveRDS(model_summary, "results/models/regression_summary.rds")
```

### What Cannot Be Committed

❌ **Individual-level data**:
```R
# Individual predictions (DO NOT COMMIT)
predictions <- predict(model, newdata = patient_data)
# Keep this in /data/outputs/
```

❌ **Detailed cross-validation results**:
```R
# Per-subject CV results (DO NOT COMMIT)
cv_results <- cross_validate(model, patient_data, folds = 10)
# Keep this in /data/outputs/
```

❌ **Large output files** (>100KB):
- Pre-commit hooks will warn you
- Consider if they contain granular data

---

## Sharing Data with Collaborators

### Never Do This

- Commit data to GitHub
- Email data files
- Share via personal Dropbox/Google Drive
- Put on USB drives without encryption

### Do This Instead

**Internal collaborators (Amsterdam UMC):**

1. **myDRE shared workspaces**
   - Best for patient data
   - Secure, audited, GDPR-compliant

2. **Institutional network drives**
   - Y: drive or departmental shares
   - For non-patient research data

3. **OneDrive/SharePoint**
   - For appropriate data types
   - Check with data steward first

**External collaborators:**

1. **SURF FileSender**
   - https://filesender.surf.nl
   - Files up to 1TB
   - Automatic deletion after download
   - Use for one-time transfers

2. **Data Transfer Agreement**
   - Contact your data steward
   - Required for patient data
   - Formal process with legal review

3. **SURF Research Cloud**
   - Shared computing environment
   - External collaborators can access
   - Data stays in secure environment

**Code-only collaboration:**

GitHub is perfect for sharing analysis code! Just ensure:
- No data files committed
- No hardcoded file paths revealing structure
- No credentials in code
- Examples use synthetic/placeholder data

---

## Common Scenarios

### "I need to share a small CSV for testing"

**Don't commit it.** Instead:

```python
# Generate synthetic test data in code
import pandas as pd
import numpy as np

# Create fake data that mimics your structure
test_data = pd.DataFrame({
    'patient_id': [f'PAT{i:03d}' for i in range(10)],
    'age': np.random.randint(20, 80, 10),
    'treatment': np.random.choice(['A', 'B'], 10),
    'outcome': np.random.rand(10)
})

# Now use this for testing
print(test_data.head())
```

Or use a fixture file:

```python
from io import StringIO

# Small CSV as string (OK in code)
TEST_CSV = """patient_id,age,treatment,outcome
PAT001,45,A,0.85
PAT002,52,B,0.72
PAT003,38,A,0.91"""

test_data = pd.read_csv(StringIO(TEST_CSV))
```

### "My analysis creates hundreds of output files"

Keep them in `/data/outputs/`:

```R
# Create output directory (Git-ignored)
dir.create("data/outputs/predictions", recursive = TRUE)

# Save individual predictions here
for (i in 1:nrow(patients)) {
  pred <- predict_outcome(patients[i,])
  saveRDS(pred, sprintf("data/outputs/predictions/patient_%03d.rds", i))
}

# Only commit the summary
summary <- summarize_predictions("data/outputs/predictions/")
write.csv(summary, "results/prediction_summary.csv")  # This is OK
```

### "I need to include example data in documentation"

Use clearly synthetic data:

```markdown
## Example Usage

Given a dataset with this structure:

| patient_id | age | diagnosis |
|------------|-----|-----------|
| PATIENT_001 | 45 | Type A |
| PATIENT_002 | 52 | Type B |

Run the analysis:
```R
results <- analyze_cohort("data/raw/patients.csv")
```
```

### "I accidentally committed data last week"

**Don't panic, but act immediately:**

1. **Stop** - Don't make more commits
2. **Report** - Email [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl) with subject "SECURITY INCIDENT"
3. **Include:**
   - Repository name
   - What file was committed
   - When (approximate date)
   - Is repo public or private?

**We'll help you:**
- Rewrite Git history to remove the data
- Make sure no copies remain
- Coordinate with anyone who cloned the repo

**See [SECURITY.md](../SECURITY.md#incident-response) for detailed incident response procedures.**

---

## Best Practices Checklist

Before starting work:
- [ ] Understand where data should live (`/data/` folder)
- [ ] Know how to access secure data storage (myDRE, network drives)
- [ ] Pre-commit hooks installed and tested
- [ ] Read the project's `/data/README.md`

During analysis:
- [ ] Keep all data files in `/data/` folder
- [ ] Use relative paths or environment variables (not hardcoded paths)
- [ ] Generate synthetic data for testing/examples
- [ ] Document data sources without revealing details

Before committing:
- [ ] Run `git diff --staged` to review changes
- [ ] Check that no data files are staged
- [ ] Verify outputs contain only aggregated results
- [ ] Pre-commit hooks passed

Before sharing:
- [ ] Use approved data sharing methods (not GitHub)
- [ ] Get data steward approval for external sharing
- [ ] Ensure collaborators have proper access to secure storage

---

## Getting Help

**Questions about:**

- **What can/can't be committed:** Check [SECURITY.md](../SECURITY.md) or ask your data steward
- **Where to store data:** Contact your data steward
- **How to share data:** Contact your data steward
- **Technical issues:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)
- **False positives:** [b.vandervelde@amsterdamumc.nl](mailto:b.vandervelde@amsterdamumc.nl)

**Still unsure?** The rule is simple: If you're not certain a file is safe to commit, ask first. It's always better to check than to risk a data breach.

---

## Remember

The security system is here to help you work safely and confidently. It's not about restriction—it's about enabling you to do great research without worrying about accidentally exposing sensitive data.

When in doubt:
1. Keep data in `/data/`
2. Commit code to Git
3. Share data through approved channels
4. Ask for help when unsure

---

_This guide is maintained by Amsterdam UMC Research Software Management. Last updated: January 2026_
