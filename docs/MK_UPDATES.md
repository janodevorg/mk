# Updating mk in Your Project

This guide explains how to update the mk submodule in your project to get the latest Makefile improvements.

## Overview

mk is typically included in projects as a Git submodule. This allows you to:
- Share common Makefile functionality across projects
- Update to latest features easily
- Track specific versions for stability

## Checking Your Current Setup

### If mk is a submodule

Check if you have mk as a submodule:

```bash
git submodule status | grep mk
```

You should see something like:
```
 a0cdc78... mk (heads/development)
```

### If mk is referenced by path

Check your Makefile for:
```makefile
MK_DIR = ../../mk  # or similar relative path
```

## Updating mk Submodule

### 1. Navigate to your project root

```bash
cd /path/to/your/project
```

### 2. Update the mk submodule

To update to the latest development branch:

```bash
cd mk
git fetch origin
git checkout development
git pull origin development
cd ..
```

Or as a one-liner from your project root:

```bash
git submodule update --remote --merge mk
```

### 3. Commit the update

```bash
git add mk
git commit -m "Update mk submodule to latest development"
git push
```

## Switching mk to Use Submodule

If your project currently uses a relative path to mk, here's how to switch to a submodule:

### 1. Remove the relative path reference

Edit your Makefile and note the current MK_DIR path.

### 2. Add mk as a submodule

```bash
# For development branch (recommended for latest features)
git submodule add -b development git@github.com:janodevorg/mk.git mk

# For main branch (stable)
git submodule add git@github.com:janodevorg/mk.git mk
```

### 3. Update your Makefile

Change:
```makefile
MK_DIR = ../../mk
```

To:
```makefile
MK_DIR = ./mk
```

### 4. Commit the changes

```bash
git add .gitmodules mk Makefile
git commit -m "Add mk as submodule"
git push
```

## Verifying the Update

After updating, verify new features are available:

```bash
make help
```

For Tuist projects, check for new caching commands:

```bash
make help | grep tuist
```

## Troubleshooting

### Submodule not initialized

If you clone a project with mk submodule:

```bash
git submodule init
git submodule update
```

Or clone with submodules:

```bash
git clone --recurse-submodules <your-repo>
```

### Permission denied

Ensure you have access to the mk repository. You may need to:
- Configure SSH keys for GitHub
- Use HTTPS URL instead: `https://github.com/janodevorg/mk.git`

### Conflicts during update

If you have local changes in mk:

```bash
cd mk
git stash
git pull origin development
git stash pop  # if you want to keep local changes
cd ..
```

### Make commands not found

Ensure your Makefile includes the correct mk files:

```makefile
include $(MK_DIR)/xcode.mk    # For Xcode projects
include $(MK_DIR)/package.mk  # For Swift packages
```

## Best Practices

1. **Use development branch** for latest features
2. **Use main branch** for stability
3. **Document mk version** in your project README
4. **Update regularly** but test after updates
5. **Pin to specific commit** for CI/CD:
   ```bash
   cd mk
   git checkout <specific-commit-hash>
   cd ..
   git add mk
   git commit -m "Pin mk to specific version"
   ```

## Getting Help

- Check mk README: `cat mk/README.md`
- View available commands: `make help`
- Report issues: https://github.com/janodevorg/mk/issues