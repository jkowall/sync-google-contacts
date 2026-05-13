# Google Contacts Sync

Synchronizes contacts across Google accounts using the Google People API.

This is a local working copy derived from Michael Adler's
`sync-google-contacts` project:

https://github.com/michael-adler/sync-google-contacts

The original script is GPL licensed and credits Michael Adler as author.
Local changes are tracked in [CHANGELOG.md](CHANGELOG.md).

## License

This working copy is licensed under GPL-2.0-or-later, matching the upstream
script. See `LICENSE`.

## Python Setup

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
```

## Google Cloud Setup

1. Open Google Cloud Console:
   https://console.cloud.google.com/
2. Create or select a project for this sync tool.
3. Enable the People API:
   https://console.cloud.google.com/apis/library/people.googleapis.com
4. Configure the OAuth consent screen:
   - Open APIs & Services > OAuth consent screen.
   - Choose External for personal Gmail accounts, unless your workspace requires
     Internal.
   - Set an app name such as `Contacts Sync`.
   - Add your email as the support and developer contact.
   - Add test users for every account you plan to authenticate, for example:
     `jkowall@gmail.com` and `jonahk@spacelift.io`.
5. Create OAuth credentials:
   - Open APIs & Services > Credentials.
   - Click Create Credentials > OAuth client ID.
   - Choose Desktop app.
   - Name it something like `Contacts Sync Local`.
   - Download the JSON file.

Store OAuth desktop client JSON files outside the repository:

```text
~/.google/authdata/client_secret.json
```

If you use separate OAuth clients per account, keep them in the same private
directory and pass `--client-secret-for user=path`.

For the current local setup:

```sh
mkdir -p ~/.google/authdata
cp ~/Downloads/gmail.json ~/.google/authdata/gmail.json
cp ~/Downloads/spacelift.json ~/.google/authdata/spacelift.json
chmod 700 ~/.google ~/.google/authdata
chmod 600 ~/.google/authdata/*.json
```

## Dry Run

```sh
.venv/bin/python contacts-sync.py --dry-run --user account1@gmail.com --user account2@gmail.com
```

For the initial local test:

```sh
.venv/bin/python contacts-sync.py --dry-run --user jkowall@gmail.com --user jonahk@spacelift.io
```

With the current local OAuth files:

```sh
.venv/bin/python contacts-sync.py --dry-run \
  --user jkowall@gmail.com \
  --user jonahk@spacelift.io \
  --client-secret-for jkowall@gmail.com=~/.google/authdata/gmail.json \
  --client-secret-for jonahk@spacelift.io=~/.google/authdata/spacelift.json
```

Every run saves a timestamped JSON backup before merge processing starts:

```text
~/.google/contacts-sync-backups/YYYYMMDDTHHMMSSZ/
```

Each backup contains one JSON file per account plus `manifest.json`. Use
`--backup-dir <path>` to write backups elsewhere. `--skip-backup` exists for
special cases, but do not use it for real sync runs.

The first run opens a local OAuth callback server on port `8765` by default. If
the browser is on a different host, tunnel the callback port first:

```sh
ssh -L 8765:127.0.0.1:8765 <this-host>
```

To use a different local callback port:

```sh
GOOGLE_OAUTH_LOCAL_PORT=8766 .venv/bin/python contacts-sync.py --dry-run --user account1@gmail.com --user account2@gmail.com
```

## Fallback Plan

1. Run with `--dry-run` first and confirm the backup directory was created.
2. Keep the latest pre-sync backup until both Google accounts look correct.
3. If a real sync produces bad changes, stop running sync immediately.
4. Use the timestamped JSON backup as the source of truth for manual recovery or
   for a future restore helper script.
5. Google Contacts also provides export and restore tools in the web UI; use
   those alongside the JSON backup for high-risk runs.
