# Contributing

Thanks for considering a contribution to `users-web`.

## Branching

This repo follows the sweetrpg platform's git-flow convention:

* `develop` is the integration branch. All feature and fix branches merge here.
* `master` reflects the latest released state. Nothing is committed here directly.
* Branch names: `feature/<description>` for new functionality, `fix/<description>` for bug
  fixes, `hotfix/<description>` for urgent fixes to a released version.

```bash
git checkout develop
git pull
git checkout -b feature/my-change
# ... work, commit ...
git push -u origin feature/my-change
# open a PR: feature/my-change -> develop
```

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

## Running checks locally

```bash
swift build
swift test
swift format lint --recursive --strict Sources Tests
```

No application source exists in this repo yet - these commands won't do anything meaningful
until a Vapor app (`Package.swift`, `Sources/`, `Tests/`) lands. This repo's CI/release/Docker
workflows are already wired up ahead of that, matching `catalog-web`'s/`admin-web`'s stack, so
they're ready to run as soon as real source is added.

## Pull requests

CI runs automatically on PRs targeting `develop`. Once checks pass and the PR is reviewed, it
can be merged (auto-merge is enabled once required checks pass).

## Releases

Versions are tagged from `develop` via the "Prepare Release" workflow (`workflow_dispatch`),
which opens a release PR with an updated `CHANGELOG.md` for review before tagging.
