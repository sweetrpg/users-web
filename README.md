# SweetRPG Users Web

[![CI](https://github.com/sweetrpg/users-web/actions/workflows/ci.yaml/badge.svg)](https://github.com/sweetrpg/users-web/actions/workflows/ci.yaml)
[![License](https://img.shields.io/github/license/sweetrpg/users-web.svg)](https://img.shields.io/github/license/sweetrpg/users-web.svg)
[![Issues](https://img.shields.io/github/issues/sweetrpg/users-web.svg)](https://img.shields.io/github/issues/sweetrpg/users-web.svg)
[![PRs](https://img.shields.io/github/issues-pr/sweetrpg/users-web.svg)](https://img.shields.io/github/issues-pr/sweetrpg/users-web.svg)
[![Dependabot](https://badgen.net/github/dependabot/sweetrpg/users-web)](https://badgen.net/github/dependabot/sweetrpg/users-web)
[![Deployment](https://argocd.dev.pilgrimagesoftware.com/api/badge?name=sweetrpg-users-web&revision=true&showAppName=true&namespace=sweetrpg-system)](https://argocd.dev.pilgrimagesoftware.com/applications/sweetrpg-users-web)

[![Swift](https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white)

Planned server-rendered Vapor (Swift) frontend for the SweetRPG platform's user-profile domain -
same stack and structural model as [catalog-web](https://github.com/sweetrpg/catalog-web) and
[admin-web](https://github.com/sweetrpg/admin-web).

## Status

Infrastructure-only: repo scaffolding (CI, release automation, Docker build, Kubernetes
manifests) is in place ahead of any application code, so the ArgoCD `Application` already
defined in `sweetrpg/kubernetes` (`clusters/dev/users/web.yaml`) has something to deploy once a
real Vapor app lands. No `Package.swift`/`Sources/`/`Tests/` exist yet - see
[CONTRIBUTING.md](CONTRIBUTING.md) for local development commands, which won't do anything
meaningful until that source is added.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow and `AGENTS.md` for
project conventions.
