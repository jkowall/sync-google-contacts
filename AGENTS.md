# Repository Instructions

## Scope

These instructions apply to this repository.

## Project

This is a local working fork of Michael Adler's `sync-google-contacts` project:

https://github.com/michael-adler/sync-google-contacts

The script synchronizes Google contacts across accounts using the Google People
API. Preserve the upstream GPL-2.0-or-later licensing and author attribution.

## Development

- Use Python 3.11 or newer.
- Keep runtime dependencies in `requirements.txt`.
- Keep test-only dependencies in `requirements-dev.txt`.
- Do not add `gdata` or `oauth2client`; both are deprecated for this project.
- Avoid live Google API calls in unit tests. Mock credentials, OAuth flows, and
  API clients instead.
- Keep contact-changing behavior behind `--dry-run` during manual validation.

## Validation

Run the smallest useful checks before committing:

```sh
.venv/bin/python -m py_compile contacts-sync.py
.venv/bin/python -m pytest
```

If dependencies are missing:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt -r requirements-dev.txt
```

## Release Safety

- Never commit OAuth secrets, token files, contact exports, or state files.
- Keep `~/.google/authdata/client_secret.json` and generated credentials outside
  this repository.
- Prefer dry-run examples in docs.
