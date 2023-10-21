This repository automates building [Odin] and its supported backends from source as a smoke test for issues with reproducibility.

[Odin]: https://github.com/odin-lang/Odin

# Using

The following script builds a slimmed LLVM toolchain, then uses it to build Odin.

```sh
./bootstrap_llvm.sh
```

Artifacts containing distributable bundles may be found in the following:

- https://github.com/jcmdln/odin-bootstrap/actions/workflows/llvm.yml

Click the latest successful pipeline for the list of generated artifacts.

**NOTE**: actions/upload-artifact breaks file permissions! https://github.com/actions/upload-artifact/issues/38

```sh
# After downloading an artifact, fix permissions and test Odin
unzip odin-linux-llvm-*.zip -d odin
cd odin
chmod +x {libLLVM-*.so,odin}
./odin run examples/demo/demo.odin -file
```

## Linux

Some minimum requirements and additional steps are needed for distributable bundles.

- CXXABI v1.3.13+
- GLIBC v2.34+
- GLIBCXX v3.4.30+

### Debian 12+ (Bookworm) / Ubuntu 22.04+

```sh
sudo apt-get install --no-install-{recommends,suggests} ca-certificates clang curl unzip
```

### Fedora 38+ / CentOS Stream 9+

```sh
sudo dnf install clang curl unzip
```

# Special Thanks

- https://github.com/odin-lang/Odin
- https://github.com/llvm/llvm-project
- https://reproducible-builds.org
- https://bootstrappable.org
