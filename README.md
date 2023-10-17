This repository automates building [Odin] and its supported backends from source as a smoke test for issues with reproducibility.

[Odin]: https://github.com/odin-lang/Odin

# Using

Artifacts containing distributable bundles may be found in the following:

- https://github.com/jcmdln/odin-bootstrap/actions/workflows/llvm.yml

Click the latest successful pipeline for the list of generated artifacts.

## Linux

Some additional steps may be needed for the distributable bundles to work.

### Debian / Ubuntu

```sh
sudo apt-get install --no-install-{recommends,suggests} clang llvm-dev libncurses-dev
```

### Fedora / CentOS

```sh
sudo dnf install clang llvm-devel ncurses-libs
```

# Special Thanks

- https://github.com/odin-lang/Odin
- https://github.com/llvm/llvm-project
- https://reproducible-builds.org
- https://bootstrappable.org
