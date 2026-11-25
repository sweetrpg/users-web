# AGENTS.md

This file provides guidance to Claude Code, Codex, GitHub Copilot, and other coding agents
working in this repository.

## About This Project

`users-web` is the server-rendered Vapor (Swift, Leaf templates) frontend for the SweetRPG
platform's user-profile domain, served behind Traefik at the `/users` path prefix. It has three
pages, each a controller in `Sources/App/Controllers` with a template in `Resources/Views`:

- **Profile** (`/profile`, `ProfileController`): shows and inline-edits the signed-in user's
  name, username, bio and website (`Public/profile-inline-edit.js` sends each field to
  `POST /profile` as JSON), and shows the terms of service version and date the user accepted,
  with links to `/terms` and `/privacy`.
- **Settings** (`/settings`, `SettingsController`): linked login identities.
- **Friends** (`/friends`, `FriendsController`).

Conventions this repo follows, shared with `catalog-web` and `admin-web`:

- **Path prefix**: Ingress strips `/users` before a request reaches the app, so routes are
  registered unprefixed. Every link or redirect to a page of this app is built from
  `INGRESS_BASE_PATH` (`req.basePath`, `meta.basePath` in templates). Links to pages other apps
  serve (the suite home page, `/terms`, `/privacy`) hang off `ROOT_URL` (`meta.rootURL`)
  instead; `main-web` serves them at the site root, not under `/users`.
- **Session**: read-only. `Sources/App/Services/SessionUserAccess.swift` reads the session
  `auth-web` writes into its Redis instance (`SHARED_SESSION_REDIS_*`); this app never writes it.
  `AuthRequiredMiddleware` redirects anonymous visitors to `/auth/login?return_to=...`.
- **Backend**: `Sources/App/Clients/UsersAPIClient.swift` calls `users-api` (`USERS_API_URL`)
  with the user's own access token as a bearer credential.
- **Localization**: no hardcoded user-facing text in templates. Strings live in
  `Resources/Localizations/<code>.json` and are read as `meta.l10n.<key>`; English is the
  fallback.

The Kubernetes manifests (`kubernetes/base/`, `kubernetes/overlays/{dev,local}/`) deploy it via
the ArgoCD `Application` at `clusters/dev/users/web.yaml` in `sweetrpg/kubernetes`.

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

CI/PR validation workflows run the same three commands on every push and PR against `develop`.

## Platform Conventions and Decisions

This repo is a submodule of `sweetrpg/platform`. Platform-wide conventions and Architecture
Decision Records live there:

- checked out inside the platform tree: `../../docs/README.md` (convention index) and
  `../../docs/adr/README.md` (platform ADRs, `PADR-*`)
- standalone or module-only checkout:
  <https://github.com/sweetrpg/platform/tree/master/docs> and
  <https://github.com/sweetrpg/platform/tree/master/docs/adr>

Accepted `PADR-*` records are binding constraints. Read the ADR index before proposing a
structural change; if a task needs to contradict an accepted record, stop and say so -
propose a superseding ADR rather than working around it. This repo's own service-local
decisions are `ADR-*` and belong in `docs/adr/` here.

Before implementing any feature, complete the
[feature work checkpoint](https://github.com/sweetrpg/platform/blob/master/docs/openspec.md#feature-work-checkpoint)
and record the answers in the issue or PR.
