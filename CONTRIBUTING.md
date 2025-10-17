# Contributing to Vector Helm Charts

Thank you for your interest in contributing to the Vector Helm Charts repository. This document provides guidelines and instructions for contributing to this project.

## Getting Started

### Prerequisites

Before contributing, ensure you have the following tools installed:

- [Helm](https://helm.sh/docs/intro/install/)
- [helm-docs](https://github.com/norwoodj/helm-docs)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Docker](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/downloads)

## Development Workflow

### 1. Fork and Clone

1. [Fork the repository on GitHub](https://github.com/vectordotdev/helm-charts/fork)
2. Clone your fork locally:

   ```bash
   git clone https://github.com/YOUR_USERNAME/helm-charts.git
   cd helm-charts
   ```

3. Add the upstream repository:

   ```bash
   git remote add upstream https://github.com/vectordotdev/helm-charts.git
   ```

### 2. Create a Feature Branch

Always create a new branch for your changes:

```bash
git checkout -b feature/your-feature-name
```

Use descriptive branch names that indicate the purpose of your changes.

### 3. Making Changes

#### Chart Development

- Make changes to the relevant chart in the `charts/` directory
- Update documentation in `README.md.gotmpl` (not `README.md` directly) and then run `helm-docs`
- Test your changes thoroughly

### 4. Submit Pull Request

1. Push your branch to your fork:

   ```bash
   git push origin feature/your-feature-name
   ```

2. Create a pull request against the `develop` branch (not `master`)

3. Fill out the PR template with:
   - Clear description of changes
   - Testing steps
   - Related issues (if any)

4. Make sure the PR title follows the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(scope): <description>
```

Examples:
- `feat(vector): add support for custom annotations`
- `fix(vector): correct RBAC permissions for metrics`
- `docs(vector): update configuration examples`
- `chore(deps): update helm-docs version`

All allowed `scope`s and `type`s can be found [here](https://github.com/vectordotdev/helm-charts/blob/develop/.github/semantic.yml)
## Pull Request Guidelines

### PR Requirements

- [ ] Target the `develop` branch
- [ ] Include clear description of changes
- [ ] Update documentation if needed
- [ ] Add tests for new functionality
- [ ] PR title follows the [Conventional Commits](https://www.conventionalcommits.org/) format
- [ ] Ensure CI checks pass

### Review Process

1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, maintainers will merge your PR
4. Your changes will be included in the next release, which should be in the same day or before the Vector release. See the [Vector public calendar](https://calendar.vector.dev)

## Issue Reporting

### Before Reporting

- Search existing issues to avoid duplicates
- Test with the latest chart version
- Gather relevant information (Kubernetes version, Helm version, chart values)
