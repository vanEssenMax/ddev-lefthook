[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/vanEssenMax/ddev-lefthook/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/vanEssenMax/ddev-lefthook/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/vanEssenMax/ddev-lefthook)](https://github.com/vanEssenMax/ddev-lefthook/commits)
[![release](https://img.shields.io/github/v/release/vanEssenMax/ddev-lefthook)](https://github.com/vanEssenMax/ddev-lefthook/releases/latest)

# DDEV Lefthook

## Overview

This add-on integrates Lefthook into your [DDEV](https://ddev.com/) project.

## Installation

```bash
ddev add-on get vanEssenMax/ddev-lefthook
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev describe` | View service status and used ports for Lefthook |
| `ddev logs -s lefthook` | Check Lefthook logs |

## Advanced Customization

To change the Docker image:

```bash
ddev dotenv set .ddev/.env.lefthook --lefthook-docker-image="ddev/ddev-utilities:latest"
ddev add-on get vanEssenMax/ddev-lefthook
ddev restart
```

Make sure to commit the `.ddev/.env.lefthook` file to version control.

All customization options (use with caution):

| Variable | Flag | Default |
| -------- | ---- | ------- |
| `LEFTHOOK_DOCKER_IMAGE` | `--lefthook-docker-image` | `ddev/ddev-utilities:latest` |

## Credits

**Contributed and maintained by [@vanEssenMax](https://github.com/vanEssenMax)**
