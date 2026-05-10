# Project 01 — Linux Ops Lab & Git Workflow

![Status](https://img.shields.io/badge/status-complete-brightgreen)
![Phase](https://img.shields.io/badge/phase-1%2F4-purple)
![Week](https://img.shields.io/badge/week-1-blue)

## Overview
A hands-on Linux sysadmin lab and professional Git workflow setup.
Part of my 4-month GitOps DevOps Engineer learning journey.

## What I Built
- Hardened Ubuntu 22.04 environment (WSL2 / Multipass VM)
- SSH key-based authentication setup
- UFW firewall configuration
- System health monitoring scripts
- Professional Git branching workflow with branch protection

## Technologies Used
`Linux` `Bash` `SSH` `Git` `GitHub` `UFW` `systemd`

## Key Concepts Learned
- Linux Filesystem Hierarchy (FHS) and why it matters
- File permissions (chmod/chown) — the 755/600/644 pattern
- Process management with systemd, ps, kill signals
- SSH Ed25519 key generation and ~/.ssh/config management
- Git branching strategy: feat/* chore/* fix/* hotfix/*
- Conventional Commits standard
- Branch protection rules on GitHub

## Scripts
| Script | Description |
|---|---|
| `scripts/health-check.sh` | CPU, memory, disk report |
| `scripts/user-provision.sh` | Idempotent user creation |
| `scripts/log-monitor.sh` | Watch logs for error patterns |

## How to Run
```bash
git clone git@github.com:yourusername/devops-gitops-journey.git
cd devops-gitops-journey/projects/01-linux-git
chmod +x scripts/*.sh
./scripts/health-check.sh
```

## Lessons Learned
> See [docs/learnings.md](./docs/learnings.md) for detailed notes.

Key insight: Understanding *why* Linux has /etc, /var, /opt 
makes every DevOps tool's config path make immediate sense.

## Next Project
→ [Project 02: Bash Automation Suite](../02-bash-automation/)
