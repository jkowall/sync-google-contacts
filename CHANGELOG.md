# Changelog

## Local working copy

Based on Michael Adler's `sync-google-contacts`:

https://github.com/michael-adler/sync-google-contacts

### Changed

- Created a local working directory at `/home/jkowall/contacts-sync-work`.
- Removed the deprecated `oauth2client` dependency.
- Kept the existing Google People API implementation using `googleapiclient`.
- Added `requirements.txt` for the current Google Python client libraries.
- Added setup and dry-run notes in `README.md`.
- Treated missing `--private` arguments as an empty list.
- Added an explicit GPL-2.0 `LICENSE` file matching the upstream script.
- Added a GitHub Actions test workflow for Python 3.11, 3.12, and 3.13.

### Validation

- Verified the updated script with `py_compile`.
- Verified command-line parsing with `contacts-sync.py --help`.
