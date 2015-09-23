# AGL

## Repositories setup

After the ``git clone`` occured, following steps are required:
```bash
cd AGL
git submodule init
git submodule update
```

## Yocto-switchto

When main and sub-repositories are catched on your machine, an helper script setup the Yocto base release by selecting the appropriate SHA-1 of submodules. This feature is like a simpler "repo" tool. It requires the submodules to be clean before "switching" to another set of releases.

Note: ** NEVER ** do a ``git submodule update`` after the submodules has been
selected using Yocto-switchto, otherwise your selection will be dropped!

### Prepare a build for Yocto-1.7

```bash
yocto-switchto.py base-1.7
```

### Prepare a build for Yocto-1.9

```bash
yocto-switchto.py base-1.9
```

## Build

### Option: DL_DIR and SSTATE_CACHE override

```bash
export DL_DIR=/your/path/to/shared/download-dir
export SSTATE_DIR=/your/path/to/shared/sstate-cache-dir
```

### Launch the build

 * For Qemu:
   ```bash
   ./build_qemu.sh [opt-build-dir]
   ```

 * For Porter/Koelsch board:
   ```bash
   ./build_porter.sh [opt-build-dir]
   ```

 * For Silk board:
   ```bash
   ./build_silk.sh [opt-build-dir]
   ```

with:

**opt-build-dir**: default is build, specify another target directory 

## git submodules uses

git submodules are in place to easily clone required Yocto layers for a full distro build.

The git submodule feature brings some constraints on branches hierarchy across sub-modules and also in parent's git repository. For now, we are using this feature more like the "repo" tool, in order to checkout appropriate submodule releases when needed.

Thus, **all the submodule does not require commit**.

### Tips

```bash
git submodule foreach git status
git submodule foreach git fetch -p -t
```

