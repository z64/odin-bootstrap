This repository automates building [Odin] and its supported backends from source as a smoke test for issues with reproducibility.

[Odin]: https://github.com/odin-lang/Odin

# Using

Artifacts containing distributable bundles may be found in the following:

- https://github.com/jcmdln/odin-bootstrap/actions/workflows/llvm.yml

Click the latest successful pipeline for the list of generated artifacts.

**NOTE**: actions/upload-artifact breaks file permissions! https://github.com/actions/upload-artifact/issues/38

```sh
# After downloading an artifact, fix permissions and test Odin
unzip odin-linux-llvm-* -d odin
chmod +x odin/{libLLVM-*.so,odin}
./odin/odin run odin/examples/demo/demo.odin -file
```

## Linux

Some additional steps may be needed for distributable bundles.

### Debian / Ubuntu

```sh
sudo apt-get install --no-install-{recommends,suggests} clang libncurses-dev
```

### Fedora / CentOS

```sh
sudo dnf install clang ncurses-libs
```

# Special Thanks

- https://github.com/odin-lang/Odin
- https://github.com/llvm/llvm-project
- https://reproducible-builds.org
- https://bootstrappable.org
