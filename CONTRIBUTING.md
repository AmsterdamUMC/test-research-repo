# Contributing Guidelines

Thank you for considering a contribution to this repository!

This project is structured for secure and reproducible research.
Please follow the guidelines below to help maintain quality,
transparency, and data protection.

---

## What you can contribute

We welcome:

- Improvements to code or analysis scripts
- Documentation and reproducibility enhancements
- Suggestions for better data handling or security
- Bug fixes or test coverage additions

---

## Reproducibility Practices

- Scripts should be **runnable end-to-end** without manual intervention
- For R:
  - Use `renv::snapshot()` to manage package environments
  - Use `here::here()` or `Sys.getenv()` instead of hardcoded paths
  - Include `sessionInfo()` in final scripts or notebooks
- For Python:
  - Use `requirements.txt` or `environment.yml`
  - Avoid OS-specific paths; use `os.path` or `pathlib`
- Consider using Quarto or R Markdown for reproducible reporting

---

## Security and Data Handling

We enforce a strict **no data** and **no secrets** in Git policy.

Do **not** commit:

- `.csv`, `.xlsx`, `.RData`, `.sav`, `.json` data files
- Secrets, API keys, tokens, passwords
- Output files from private datasets

**Instead:**

- Add those file types to `.gitignore`
- Use environment variables or a separate config file (not tracked by git)
- Document how to access secure data in `README.md` (without revealing actual paths or content)

See [`SECURITY.md`](./SECURITY.md) for full policy.

---

## Pull Request Checklist

Before opening a pull request, make sure:

- [ ] Your code runs and is documented
- [ ] You did **not** include any sensitive data
- [ ] You added/updated `.gitignore` if needed
- [ ] You updated the README or relevant documentation
- [ ] GitHub Actions workflows pass (no red ❌)

---

## How to Contribute

1. Fork the repository
2. Create a feature branch:

   ```bash
   git checkout -b feature/my-improvement
   ```
