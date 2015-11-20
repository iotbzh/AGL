# AGL

## Repositories setup

After the ``git clone`` occured, user can put in place a release with snap.sh tool
```bash
./snap.sh < custom_manifest
```

And, on same principle use the ./conf.sh script to put back custom build files such
as 'bblayers.conf' and 'local.conf'.
```bash
./conf.sh < custom_conffile
```

## Build

### Option: DL_DIR and SSTATE_CACHE override

```bash
export DL_DIR=/your/path/to/shared/download-dir
export SSTATE_DIR=/your/path/to/shared/sstate-cache-dir
```

### Launch the build

   ```bash
   ./build-terminal.sh <target-name> [<build-dir>]
   ```

with:

**build-dir**: default is build, specify another target directory if needed 

   ```bash
   bitbake agl-demo-platform
   ```
