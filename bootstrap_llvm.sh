#!/usr/bin/env sh

set -eux

: ${CC=clang}
: ${CXX=clang++}
: ${LD=lld}

: ${CMAKE_GENERATOR="Unix Makefiles"}
: ${LLVM_BRANCH=llvmorg-17.0.2}
: ${LLVM_SOURCE=https://github.com/llvm/llvm-project}
: ${ODIN_BRANCH=master}
: ${ODIN_SOURCE=https://github.com/odin-lang/Odin}

if [ -e "$(command -v ninja)" ]; then
	CMAKE_GENERATOR="Ninja"
fi

#
# LLVM
#

LLVM_PATH="$PWD/llvm-project"
LLVM_BUILD_PATH="$LLVM_PATH/build"
LLVM_BIN_PATH="$LLVM_BUILD_PATH/bin"
LLVM_SOURCE_PATH="$LLVM_PATH/llvm"

if [ ! -d "$(basename $LLVM_SOURCE)" ]; then
	git clone --branch="$LLVM_BRANCH" --depth=1 $LLVM_SOURCE
fi

if [ ! -d "$LLVM_BUILD_PATH" ]; then
	mkdir -p $LLVM_BUILD_PATH
fi

llvm_cmake() {
	cmake -Wno-dev -G "$CMAKE_GENERATOR" -B $LLVM_BUILD_PATH -S $LLVM_SOURCE_PATH \
		-DCMAKE_BUILD_TYPE:STRING="Release" \
		-DLLVM_ENABLE_PROJECTS:STRING="clang;compiler-rt;lld" \
		-DLLVM_TARGETS_TO_BUILD:STRING="AArch64;ARM;WebAssembly;X86" \
		-DLLVM_INCLUDE_TOOLS:BOOL=FORCE_ON \
		-DLLVM_BUILD_LLVM_DYLIB:BOOL=FORCE_ON \
		-DLLVM_LINK_LLVM_DYLIB:BOOL=FORCE_ON \
		-DCLANG_BUILD_EXAMPLES:BOOL=OFF \
		-DCLANG_INCLUDE_DOCS:BOOL=OFF \
		-DCLANG_INCLUDE_TESTS:BOOL=OFF \
		-DCLANG_TOOL_APINOTES_TEST_BUILD:BOOL=OFF \
		-DCLANG_TOOL_ARCMT_TEST_BUILD:BOOL=OFF \
		-DCLANG_TOOL_C_ARCMT_TEST_BUILD:BOOL=OFF \
		-DCLANG_TOOL_C_INDEX_TEST_BUILD:BOOL=OFF \
		-DCLANG_TOOL_CLANG_IMPORT_TEST_BUILD:BOOL=OFF \
		-DCOMPILER_RT_INCLUDE_TESTS:BOOL=OFF \
		-DLLVM_BUILD_BENCHMARKS:BOOL=OFF \
		-DLLVM_BUILD_EXAMPLES:BOOL=OFF \
		-DLLVM_BUILD_UTILS:BOOL=OFF \
		-DLLVM_ENABLE_BACKTRACES:BOOL=OFF \
		-DLLVM_ENABLE_BINDINGS:BOOL=OFF \
		-DLLVM_ENABLE_CRASH_OVERRIDES:BOOL=OFF \
		-DLLVM_ENABLE_LIBEDIT:BOOL=OFF \
		-DLLVM_ENABLE_LIBPFM:BOOL=OFF \
		-DLLVM_ENABLE_LIBXML2:BOOL=OFF \
		-DLLVM_ENABLE_TERMINFO:BOOL=OFF \
		-DLLVM_ENABLE_ZSTD:BOOL=OFF \
		-DLLVM_INCLUDE_BENCHMARKS:BOOL=OFF \
		-DLLVM_INCLUDE_DOCS:BOOL=OFF \
		-DLLVM_INCLUDE_EXAMPLES:BOOL=OFF \
		-DLLVM_INCLUDE_TESTS:BOOL=OFF \
		-DLLVM_INCLUDE_UTILS:BOOL=OFF \
		-DLLVM_TOOL_LLVM_C_TEST_BUILD:BOOL=OFF \
		$@
}

llvm_build() {
	if [ -e "$(command -v ccache)" ]; then
		llvm_cmake -DLLVM_CCACHE_BUILD:BOOL=FORCE_ON $@
	else
		llvm_cmake $@
	fi
}

case "$(uname -s)" in
Darwin)
	llvm_build -DLLVM_BUILD_LLVM_C_DYLIB:BOOL=FORCE_ON
	;;
*)
	llvm_build
	;;
esac

if [ -e "$(command -v ninja)" ]; then
	ninja -C $LLVM_BUILD_PATH
else
	_cwd=$PWD
	cd $LLVM_BUILD_PATH
	make
	cd $_cwd
	unset _cwd
fi

#
# Odin
#

if [ ! -d "$(basename $ODIN_SOURCE)" ]; then
	git clone --branch="$ODIN_BRANCH" --depth=1 $ODIN_SOURCE
fi

cd "$(basename $ODIN_SOURCE)"

CXX="$LLVM_BIN_PATH/clang++" \
CXX_LD="$LLVM_BIN_PATH/lld" \
LLVM_CONFIG="$LLVM_BIN_PATH/llvm-config" \
./build_odin.sh release
