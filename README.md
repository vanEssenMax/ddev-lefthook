[![tests](https://github.com/vanEssenMax/ddev-lefthook/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/vanEssenMax/ddev-lefthook/actions/workflows/tests.yml)
[![last commit](https://img.shields.io/github/last-commit/vanEssenMax/ddev-lefthook)](https://github.com/vanEssenMax/ddev-lefthook/commits)
[![release](https://img.shields.io/github/v/release/vanEssenMax/ddev-lefthook)](https://github.com/vanEssenMax/ddev-lefthook/releases/latest)

# ddev-lefthook

Git hooks that install themselves.

[lefthook](https://lefthook.dev) is a great git hooks manager with one
classic failure mode: somebody has to run `lefthook install`. On every
machine. After every clone. Someone always forgets, and the commit that
slips through is exactly the one your pre-commit hook existed to catch.

This add-on removes the human from that loop. On every `ddev start` it:

1. checks that the lefthook binary exists on the host, installing it via
   brew, bun, or npm when it does not,
2. runs `lefthook install`, which wires `.git/hooks` to your project's
   lefthook config, and
3. lets lefthook drop its commented example `lefthook.yml` when the
   project has no config yet, so you start from something instead of
   nothing.

Hooks run where commits happen: on the host. The web container never
sees them, which is why this is a host command and not another service.

Opinions this add-on holds:

- `ddev start` must never fail because of git hook tooling. Anything
  missing produces a yellow warning and a working project.
- Your lefthook config is yours. The add-on ships zero hook definitions
  and will never touch the file.
- Noise is a bug. When there is nothing to do, the output stays dim, and
  `NO_COLOR` is respected.

## Install

```bash
ddev add-on get vanEssenMax/ddev-lefthook
ddev restart
```

That is the entire setup. Commit the two files it adds and every
teammate gets working hooks on their next `ddev start`, whether they
read the onboarding doc or not. Upgrading later is the same command
again, and `ddev add-on remove lefthook` unwires the hooks from
`.git/hooks` on the way out (your lefthook config stays, obviously).

| File | Purpose |
| ---- | ------- |
| `.ddev/commands/host/lefthook` | The `ddev lefthook` command |
| `.ddev/config.lefthook.yaml` | The `post-start` hook that calls it |

`ddev lefthook` on its own wires the hooks; that is exactly what the
`post-start` hook calls, and it never fails your `ddev start`. Anything
after it goes straight to the lefthook binary with honest exit codes:
`ddev lefthook run pre-commit`, `ddev lefthook validate`, whatever the
[lefthook CLI](https://lefthook.dev/usage/commands.html) understands.
Either way the binary is installed first when missing.

## Configuring the installer

By default the add-on probes `brew`, `bun`, `npm`, and `winget`,
installing lefthook with the first one it finds. Prefer a different
order, or no installing at all:

```bash
ddev dotenv set .ddev/.env.lefthook --lefthook-installer "bun,brew"
ddev restart
```

Commit `.ddev/.env.lefthook` if the whole team should share that
preference; leave it uncommitted to keep it personal.

| `LEFTHOOK_INSTALLER` | Behavior |
| -------------------- | -------- |
| `auto` (default) | Probe `brew`, `bun`, `npm`, `winget` in that order |
| A comma-separated subset, like `bun,brew` | Probe only these, in your order |
| `none` | Never install the binary; only warn when it is missing |

Already have lefthook on your `PATH`? Then none of this matters: the
installer step is skipped entirely.

## Releasing (maintainers)

Tag it and walk away:

```bash
git tag v1.x.y && git push --tags
```

A workflow publishes the GitHub release with generated notes.

## Credits

**Contributed and maintained by [@vanEssenMax](https://github.com/vanEssenMax)**
