import importlib.util
import json
from pathlib import Path

import pytest


MODULE_PATH = Path(__file__).resolve().parents[1] / "contacts-sync.py"


def load_module():
    spec = importlib.util.spec_from_file_location("contacts_sync", MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_oauth_local_port_defaults_to_8765(monkeypatch):
    module = load_module()
    monkeypatch.delenv(module.OAUTH_LOCAL_PORT_ENV, raising=False)

    assert module._oauth_local_port() == 8765


def test_oauth_local_port_uses_environment(monkeypatch):
    module = load_module()
    monkeypatch.setenv(module.OAUTH_LOCAL_PORT_ENV, "9876")

    assert module._oauth_local_port() == 9876


def test_oauth_local_port_rejects_non_integer(monkeypatch):
    module = load_module()
    monkeypatch.setenv(module.OAUTH_LOCAL_PORT_ENV, "not-a-port")

    with pytest.raises(RuntimeError, match=module.OAUTH_LOCAL_PORT_ENV):
        module._oauth_local_port()


def test_oauth_bind_addr_defaults_to_none(monkeypatch):
    module = load_module()
    monkeypatch.delenv(module.OAUTH_BIND_ADDR_ENV, raising=False)

    assert module._oauth_bind_addr() is None


def test_oauth_bind_addr_uses_environment(monkeypatch):
    module = load_module()
    monkeypatch.setenv(module.OAUTH_BIND_ADDR_ENV, "0.0.0.0")

    assert module._oauth_bind_addr() == "0.0.0.0"


def test_arg_parser_requires_user():
    module = load_module()
    parser = module.build_arg_parser()

    with pytest.raises(SystemExit):
        parser.parse_args(["--dry-run"])


def test_arg_parser_allows_multiple_users_and_private_groups():
    module = load_module()
    parser = module.build_arg_parser()

    args = parser.parse_args([
        "--dry-run",
        "--user",
        "one@example.com",
        "--user",
        "two@example.com",
        "--private",
        "Family",
    ])

    assert args.dry_run is True
    assert args.user == ["one@example.com", "two@example.com"]
    assert args.private == ["Family"]


def test_safe_filename_removes_unsafe_characters():
    module = load_module()

    assert module.safe_filename("one+two@example.com") == "one_two@example.com"


def test_resolve_client_secrets_maps_user_specific_paths():
    module = load_module()

    default_secret, user_secrets = module.resolve_client_secrets(
        "~/.google/authdata/client_secret.json",
        ["one@example.com=/tmp/one.json", "two@example.com=/tmp/two.json"],
    )

    assert default_secret == "~/.google/authdata/client_secret.json"
    assert user_secrets == {
        "one@example.com": "/tmp/one.json",
        "two@example.com": "/tmp/two.json",
    }


def test_resolve_client_secrets_rejects_invalid_mapping():
    module = load_module()

    with pytest.raises(RuntimeError, match="user=path"):
        module.resolve_client_secrets("default.json", ["not-a-mapping"])


def test_backup_contacts_writes_manifest_and_user_files(tmp_path):
    module = load_module()

    class FakeContacts:
        def GroupIterItems(self):
            return iter({
                "contactGroups/family": {"name": "Family"},
            }.items())

        def ContactIterItems(self):
            return iter({
                "uid-1": {"names": [{"displayName": "Test User"}]},
            }.items())

    backup_dir = module.backup_contacts(["one@example.com"], [FakeContacts()], str(tmp_path))
    backup_path = Path(backup_dir)

    manifest = json.loads((backup_path / "manifest.json").read_text(encoding="utf-8"))
    user_backup = json.loads((backup_path / "one@example.com.json").read_text(encoding="utf-8"))

    assert backup_path.is_dir()
    assert manifest["users"] == [{
        "user": "one@example.com",
        "file": "one@example.com.json",
        "group_count": 1,
        "contact_count": 1,
    }]
    assert user_backup["user"] == "one@example.com"
    assert user_backup["group_count"] == 1
    assert user_backup["contact_count"] == 1
