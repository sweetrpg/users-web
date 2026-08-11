# AGENTS.md

This file provides guidance to Claude Code, Codex, GitHub Copilot, and other coding agents
working in this repository.

## About This Project

`users-web` is a planned server-rendered Vapor (Swift) frontend for the SweetRPG platform's
user-profile domain. As of this writing it has no application source - `Package.swift`,
`Sources/`, and `Tests/` don't exist yet. What does exist is infrastructure scaffolding added
ahead of the app itself (see `sweetrpg/platform`'s `repo-setup-standard` skill): CI/release
workflows and Kubernetes manifests, modeled on
[`catalog-web`](https://github.com/sweetrpg/catalog-web) and
[`admin-web`](https://github.com/sweetrpg/admin-web) - same stack, same
path-prefix-behind-Traefik architecture, same read-only shared-session pattern once a login
integration is added. Read those repos' own `AGENTS.md` files for the conventions this repo is
expected to follow once real source lands, rather than duplicating them here speculatively.

The Kubernetes manifests (`kubernetes/base/`, `kubernetes/overlays/{dev,local}/`) were added by
`sweetrpg/platform`'s `finish-shared-session-rollout` OpenSpec change to unblock the ArgoCD
`Application` already defined at `clusters/dev/users/web.yaml` in `sweetrpg/kubernetes` - they
deliberately don't wire up the suite-wide shared session or any backend API calls yet, since no
application code exists to make those calls. See that change's `design.md` for the full context.

## Committing Code

[Conventional Commits](https://www.conventionalcommits.org/): `<type>(<scope>): <description>`.

## Branches and Workflow

Git-flow (see `docs/git-flow.md` in `sweetrpg/platform`): `develop` is the integration branch,
`master` reflects the latest release. Feature/fix branches off `develop`, PR back into `develop`.

## Running Checks Locally

```bash
swift build
swift test
swift format lint --recursive --strict Sources Tests
```

These won't do anything meaningful until a real Vapor app exists in this repo. CI/PR validation
workflows already run `swift build`/`swift test`/`swift format lint` on every push and PR
against `develop` - they'll start passing once real source is added, not before.
