This repository automates building [Odin] and [LLVM] with as few dependencies as possible.

[LLVM]: https://github.com/llvm/llvm-project
[Odin]: https://github.com/odin-lang/Odin

# Using

The recommended flow is to download a distributable bundle which may be found in the following:

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

Alternatively you may also use the following script to reproduce Odin locally:

```sh
$ ./bootstrap_llvm.sh
$ ldd Odin/odin
        linux-vdso.so.1 (0x00007ffca03dc000)
        libm.so.6 => /lib64/libm.so.6 (0x00007f8b7da36000)
        libstdc++.so.6 => /lib64/libstdc++.so.6 (0x00007f8b7d600000)
        libz.so.1 => /lib64/libz.so.1 (0x00007f8b7da1c000)
        libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x00007f8b7d9f8000)
        libc.so.6 => /lib64/libc.so.6 (0x00007f8b7d422000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f8b7db31000)
$ du -sh Odin/odin
78M     Odin/odin
```

## Linux

The following runtime dependencies are required for Odin to run:

- Clang in `PATH`
- CXXABI v1.3.13+
- GLIBC v2.34+
- GLIBCXX v3.4.30+

### Debian 12+ (Bookworm) / Ubuntu 22.04+

```sh
sudo apt-get install --no-install-{recommends,suggests} clang
```

### Fedora 38+ / CentOS Stream 9+

```sh
sudo dnf install clang
```

# Special Thanks

- https://github.com/odin-lang/Odin
- https://github.com/llvm/llvm-project
- https://reproducible-builds.org
- https://bootstrappable.org
