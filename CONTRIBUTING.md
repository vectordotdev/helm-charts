# Contributing to Vector Helm Charts

Thank you for your interest in contributing to the Vector Helm Charts repository. This document provides guidelines and instructions for contributing to this project.

## Getting Started

### Prerequisites

Before contributing, ensure you have the following tools installed:

- [Helm](https://helm.sh/docs/intro/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Docker](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/downloads)

### Repository Structure

```sh
.
├── charts/
│   ├── vector/            # Main Vector chart
│   ├── vector-agent/      # Deprecated agent chart
│   └── vector-aggregator/ # Deprecated aggregator chart
├── .github/
│   ├── workflows/         # CI/CD workflows
│   └── *.sh               # Release scripts
├── CHANGELOG.md           # Project changelog
└── README.md              # Repository documentation
```

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
- Update `Chart.yaml` version following [SemVer](https://semver.org/) if needed
- Update documentation in `README.md.gotmpl` (not `README.md` directly)
- Test your changes thoroughly

### 4. Commit Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(scope): <description>

[optional body]

[optional footer]
```

Examples:
- `feat(vector): add support for custom annotations`
- `fix(vector): correct RBAC permissions for metrics`
- `docs(vector): update configuration examples`

Types:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

### 6. Submit Pull Request

1. Push your branch to your fork:

   ```bash
   git push origin feature/your-feature-name
   ```

2. Create a pull request against the `develop` branch (not `master`)

3. Fill out the PR template with:
   - Clear description of changes
   - Testing steps
   - Related issues (if any)

## Pull Request Guidelines

### PR Requirements

- [ ] Target the `develop` branch
- [ ] Include clear description of changes
- [ ] Update documentation if needed
- [ ] Add tests for new functionality
- [ ] Follow conventional commit format
- [ ] Ensure CI checks pass

### Review Process

1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, maintainers will merge your PR
4. Your changes will be included in the next release

## Issue Reporting

### Before Reporting

- Search existing issues to avoid duplicates
- Test with the latest chart version
- Gather relevant information (Kubernetes version, Helm version, chart values)
