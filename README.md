[![tests](https://github.com/vanEssenMax/ddev-lefthook/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/vanEssenMax/ddev-lefthook/actions/workflows/tests.yml)
[![last commit](https://img.shields.io/github/last-commit/vanEssenMax/ddev-lefthook)](https://github.com/vanEssenMax/ddev-lefthook/commits)
[![release](https://img.shields.io/github/v/release/vanEssenMax/ddev-lefthook)](https://github.com/vanEssenMax/ddev-lefthook/releases/latest)

# DDEV Lefthook

## Overview

This add-on manages [lefthook](https://lefthook.dev) git hooks for your
[DDEV](https://ddev.com) project. On every `ddev start` it:

1. makes sure the lefthook binary exists on the host (installing it via
   brew, bun, or npm when missing),
2. runs `lefthook install`, which writes the `.git/hooks` stubs from your
   project's lefthook config, and
3. generates lefthook's commented example `lefthook.yml` when the project
   has no lefthook config yet.

Git commits happen on the host, so the binary and the hook stubs live on
the host, not in the web container. The add-on never fails `ddev start`:
when something is missing it prints a warning and moves on.

## Installation

```bash
ddev add-on get vanEssenMax/ddev-lefthook
ddev restart
```

## What gets installed

| File | Purpose |
| ---- | ------- |
| `.ddev/commands/host/install-hooks` | Host command; run manually any time with `ddev install-hooks` |
| `.ddev/config.lefthook.yaml` | Adds the `post-start` hook that calls `ddev install-hooks` |

Commit both files so your whole team gets hooks installed automatically.

## Configuration

The binary installer is configured through `.ddev/.env.lefthook`:

```bash
ddev dotenv set .ddev/.env.lefthook --lefthook-installer "bun,brew"
ddev restart
```

| `LEFTHOOK_INSTALLER` | Behavior |
| -------------------- | -------- |
| `auto` (default) | Probe `brew`, `bun`, `npm` in that order; install with the first one present |
| `bun,brew` (any comma-separated list of `brew`, `bun`, `npm`) | Probe only these, in the given order |
| `none` | Never install the binary; only warn when it is missing |

If lefthook is already on the `PATH`, the installer step is skipped
entirely regardless of this setting. Output honors `NO_COLOR`.

## Credits

**Contributed and maintained by [@vanEssenMax](https://github.com/vanEssenMax)**
