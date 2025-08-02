# Tuist Binary Framework Caching Guide

This guide explains how to use binary framework caching with Tuist through mk's Makefile commands.

## Overview

Binary framework caching allows you to pre-compile dependencies as frameworks, significantly reducing build times. Instead of building dependencies from source each time, you can use pre-built cached versions.

## Prerequisites

- Tuist installed (`brew install tuist`)
- A project configured with Tuist that supports caching (see "Project Configuration" below)

## Quick Start

### Initial Setup (One Time)

```bash
make tuist-update-cache
```

This command will:
1. Clean existing artifacts
2. Install all dependencies
3. Generate the project
4. Cache all dependencies for both Debug and Release configurations

### Daily Development Workflow

For fast builds using cached frameworks:

```bash
make generate-cached
make build
```

## Available Commands

| Command | Description |
|---------|-------------|
| `make generate` | Generate project (builds dependencies from source) |
| `make generate-cached` | Generate project using cached dependencies |
| `make tuist-clean` | Clean Tuist artifacts and dependencies |
| `make tuist-install` | Install Tuist dependencies |
| `make tuist-cache` | Cache dependencies as binary frameworks |
| `make tuist-cache-print` | Show which frameworks can be cached |
| `make tuist-cache-warm` | Cache for both Debug and Release |
| `make tuist-update` | Update dependencies and regenerate |
| `make tuist-update-cache` | Update dependencies and rebuild cache |
| `make generate-clean` | Clean generation from scratch |
| `make generate-clean-cached` | Clean generation with cached dependencies |
| `make tuist-info` | Show Tuist environment and cache status |

## Workflows

### When Dependencies Change

1. Update dependencies and rebuild cache:
   ```bash
   make tuist-update-cache
   ```

2. Continue with cached builds:
   ```bash
   make generate-cached
   ```

### Troubleshooting Build Issues

If you encounter build issues, try a clean build:

```bash
make generate-clean-cached
```

### Checking Cache Status

```bash
make tuist-info
```

This shows:
- Tuist version
- Environment variables (USE_CACHED_DEPENDENCIES)
- Cache directory location and status

## Project Configuration

For caching to work, your project needs:

1. **Project.swift** with environment variable support:
   ```swift
   let useCachedDependencies = Environment.useCachedDependencies.getBoolean(default: false)
   
   // In target dependencies:
   dependencies: useCachedDependencies ? [
       .external(name: "SomeFramework")
   ] : [
       .package(product: "SomeFramework")
   ]
   ```

2. **Tuist/Package.swift** with framework product types:
   ```swift
   let packageSettings = PackageSettings(
       productTypes: [
           "SomeFramework": .framework
       ]
   )
   ```

## Benefits

- **Faster builds**: Dependencies are pre-compiled
- **Consistent builds**: All team members use same cached frameworks
- **Easy switching**: Toggle between source/cached with environment variable
- **CI optimization**: Cache can be shared across CI builds

## Tips

- Run `make tuist-cache-print` to see what will be cached
- Use `make tuist-cache-warm` after major dependency updates
- The cache is stored in `.tuist/Cache` or `.tuist-cache`
- Add cache directories to `.gitignore`

## Troubleshooting

### Cache not being used
- Check `make tuist-info` to verify cache exists
- Ensure you're using `make generate-cached` (not `make generate`)
- Verify your Project.swift supports the USE_CACHED_DEPENDENCIES variable

### Build failures with cache
- Try `make tuist-clean` followed by `make tuist-update-cache`
- Check that all dependencies in Package.swift have framework product types

### Slow initial cache build
- First cache build compiles all dependencies - this is normal
- Subsequent builds will be much faster