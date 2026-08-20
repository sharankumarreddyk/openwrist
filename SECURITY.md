# Security Policy

## Reporting a vulnerability

Please report security issues privately via GitHub's **"Report a vulnerability"**
(Security → Advisories) rather than opening a public issue. Include steps to
reproduce and the affected component (`firmware/` or `app/`).

## Scope notes

OpenWrist handles some sensitive data. Relevant design points:

- **TOTP secrets** in the app are stored in the iOS **Keychain**, never in
  `UserDefaults`.
- **BLE bonding** uses LE Secure Connections; ANCS/AMS characteristics require
  an encrypted link before subscription.
- No credentials or secrets should ever be committed to the repository.

Because the project is pre-1.0 and hardware bring-up is ongoing, security
hardening (e.g. OTA image signing) is tracked in the roadmap and not yet
complete. Treat builds as experimental.
