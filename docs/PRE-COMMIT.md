# Pre-commit Hooks Guide

This repository uses [pre-commit](https://pre-commit.com/) to run automated checks before commits.

## Setup

### Install pre-commit

**Using Nix** (recommended):
```bash
nix-shell -p pre-commit
```

**Using Homebrew** (macOS):
```bash
brew install pre-commit
```

**Using pip**:
```bash
pip install pre-commit
```

### Install Hooks

From the repository root:

```bash
pre-commit install
```

This installs git hooks that run automatically before each commit.

## Configured Hooks

### Automatic Hooks (run on every commit)

1. **trailing-whitespace**: Removes trailing whitespace
2. **end-of-file-fixer**: Ensures files end with newline
3. **check-yaml**: Validates YAML syntax
4. **check-added-large-files**: Prevents committing files >1MB
5. **check-merge-conflict**: Detects merge conflict markers
6. **check-case-conflict**: Prevents case conflicts
7. **mixed-line-ending**: Normalizes line endings
8. **alejandra-check**: Checks Nix file formatting
9. **check-secrets**: Verifies secrets are encrypted
10. **no-large-files**: Additional large file check

### Manual Hooks (run explicitly)

1. **nix-linter**: Advanced Nix linting
2. **flake-check**: Full flake validation

Run manual hooks with:
```bash
pre-commit run --hook-stage manual --all-files
```

## Usage

### Automatic Running

Hooks run automatically when you commit:

```bash
git add file.nix
git commit -m "Update configuration"
# Hooks run automatically here
```

### Manual Running

Run all hooks on all files:

```bash
pre-commit run --all-files
```

Run specific hook:

```bash
pre-commit run alejandra-check --all-files
```

Run hooks on staged files only:

```bash
pre-commit run
```

### Skipping Hooks

**Not recommended**, but if needed:

```bash
# Skip all hooks for this commit
git commit --no-verify -m "Emergency fix"

# Skip specific hook
SKIP=alejandra-check git commit -m "Commit message"
```

## Fixing Issues

### Formatting Issues

Most formatting issues are auto-fixed:

```bash
# Run hooks to fix
pre-commit run --all-files

# Stage fixes
git add .

# Commit
git commit -m "Your message"
```

### Nix Syntax Issues

For Nix syntax errors:

1. Check the error message
2. Fix the syntax in your .nix files
3. Run hooks again:
   ```bash
   pre-commit run --all-files
   ```

### Large Files

If you accidentally try to commit a large file:

1. Remove it from staging:
   ```bash
   git reset HEAD large-file
   ```

2. Add to .gitignore if appropriate
3. Consider using Git LFS for legitimate large files

### Secret Encryption

If secrets check fails:

1. Ensure secrets are encrypted with sops:
   ```bash
   sops -e secrets/secrets.yaml
   ```

2. Verify encryption:
   ```bash
   sops -d secrets/secrets.yaml
   ```

## Updating Hooks

Update to latest hook versions:

```bash
pre-commit autoupdate
```

## Integration with CI

Pre-commit hooks should match CI checks. Our CI pipeline runs:

1. Flake check
2. Build verification
3. Format checking

Keep hooks and CI in sync to catch issues early.

## Troubleshooting

### Hooks Not Running

Reinstall hooks:

```bash
pre-commit uninstall
pre-commit install
```

### Hook Failures

Get detailed output:

```bash
pre-commit run --verbose --all-files
```

### Nix-specific Issues

Ensure Nix is in your PATH:

```bash
which nix
nix --version
```

### Alejandra Not Found

Install Alejandra:

```bash
nix profile install nixpkgs#alejandra
```

Or use Nix shell:

```bash
nix-shell -p alejandra --run "pre-commit run alejandra-check"
```

## Best Practices

1. **Commit Often**: Smaller commits make hook runs faster
2. **Fix Early**: Don't bypass hooks unless absolutely necessary
3. **Keep Updated**: Run `pre-commit autoupdate` periodically
4. **Add Custom Hooks**: Extend for project-specific needs

## Custom Hooks

Add project-specific hooks in `.pre-commit-config.yaml`:

```yaml
- repo: local
  hooks:
    - id: my-custom-check
      name: My Custom Check
      entry: ./scripts/my-check.sh
      language: system
      files: '\.nix$'
```

## Resources

- [Pre-commit Documentation](https://pre-commit.com/)
- [Alejandra Formatter](https://github.com/kamadorueda/alejandra)
- [Nix Linters](https://github.com/NixOS/nix-linters)
