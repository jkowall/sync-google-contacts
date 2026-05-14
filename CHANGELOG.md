# Changelog

## Unreleased

This fork modernizes and operationalizes Michael Adler's
`sync-google-contacts` script while preserving the original GPL-2.0-or-later
license and People API sync behavior.

### Added

- Python dependency files for runtime and test setup.
- Step-by-step Google Cloud OAuth setup documentation.
- Per-account OAuth client secret mapping with `--client-secret-for`.
- Pre-sync JSON backups with a manifest file.
- Configurable backup directory with `--backup-dir`.
- Optional `--skip-backup` flag for exceptional cases.
- WSL-friendly OAuth callback binding configuration.
- Retry and throttle handling for Google API writes.
- Daily scheduler helpers for Windows Task Scheduler with WSL and Linux cron.
- GitHub Actions test workflow for Python 3.11, 3.12, and 3.13.
- Unit tests for argument parsing, OAuth configuration helpers, and backup
  generation.

### Changed

- Removed the deprecated `oauth2client` dependency.
- Kept authentication on modern `google-auth` and `google-auth-oauthlib`.
- Made `--private` optional without requiring callers to pass an empty value.
- Added a standard `LICENSE` file matching the upstream GPL license.
- Added repository instructions in `AGENTS.md`.

### Validation

- `python -m py_compile contacts-sync.py`
- `python -m pytest`
- `bash -n scripts/run-sync.sh scripts/install-linux-cron.sh`
