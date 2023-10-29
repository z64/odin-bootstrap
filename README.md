This repository automates building [Odin] and [LLVM] with as few dependencies as possible.

[LLVM]: https://github.com/llvm/llvm-project
[Odin]: https://github.com/odin-lang/Odin

# Using

The recommended flow is to download a distributable bundle which may be found in the following:

- https://github.com/jcmdln/odin-bootstrap/actions/workflows/llvm.yml

Click the latest successful pipeline for the list of generated artifacts.

The following runtime dependencies are required for Odin distributables:

- Clang 12+ in `PATH`
- GLIBC v2.31+

Alternatively you may use `./odin_llvm.sh` to reproduce Odin locally.

## Errata

**NOTE**: actions/upload-artifact breaks file permissions! https://github.com/actions/upload-artifact/issues/38

```sh
# After downloading an artifact, fix permissions and test Odin
unzip odin-linux-llvm-*.zip -d odin
cd odin
chmod +x {libLLVM-*.so,odin}
./odin run examples/demo/demo.odin -file
```

# Special Thanks

- https://github.com/odin-lang/Odin
- https://github.com/llvm/llvm-project
- https://reproducible-builds.org
- https://bootstrappable.org
