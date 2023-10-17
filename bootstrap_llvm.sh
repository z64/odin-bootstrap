#!/usr/bin/env sh

set -eux

: ${CC:-clang}
: ${CC_LD:-lld}
: ${CXX:-clang++}
: ${CXX_LD:-lld}

: ${CMAKE_GENERATOR:-Ninja}
: ${LLVM_BRANCH:-llvmorg-17.0.2}
: ${LLVM_SOURCE:-https://github.com/llvm/llvm-project}
: ${ODIN_BRANCH:-master}
: ${ODIN_SOURCE:-https://github.com/odin-lang/Odin}

LLVM_PATH="$PWD/llvm-project"
LLVM_BUILD_PATH="$LLVM_PATH/build"
LLVM_BIN_PATH="$LLVM_BUILD_PATH/bin"
LLVM_SOURCE_PATH="$LLVM_PATH/llvm"

if [ ! -d "$(basename $LLVM_SOURCE)" ]; then
	git clone --branch="$LLVM_BRANCH" --depth=1 $LLVM_SOURCE
fi

if [ ! -d "$LLVM_BUILD_PATH" ]; then
	mkdir -p $LLVM_BUILD_PATH

	case "$(uname -s)" in
	Darwin)
		cmake -Wno-dev -G $CMAKE_GENERATOR -B $LLVM_BUILD_PATH -S $LLVM_SOURCE_PATH \
			-DCMAKE_BUILD_TYPE:STRING="Release" \
			-DLLVM_ENABLE_PROJECTS:STRING="clang;compiler-rt;lld" \
			-DLLVM_TARGETS_TO_BUILD:STRING="AArch64;ARM;WebAssembly;X86" \
			-DLLVM_CCACHE_BUILD:BOOL=FORCE_ON \
			-DLLVM_BUILD_LLVM_C_DYLIB=FORCE_ON \
			-DLLVM_BUILD_LLVM_DYLIB:BOOL=FORCE_ON \
			-DLLVM_LINK_LLVM_DYLIB:BOOL=FORCE_ON
		;;
	*)
		cmake -Wno-dev -G $CMAKE_GENERATOR -B $LLVM_BUILD_PATH -S $LLVM_SOURCE_PATH \
			-DCMAKE_BUILD_TYPE:STRING="Release" \
			-DLLVM_ENABLE_PROJECTS:STRING="clang;compiler-rt;lld" \
			-DLLVM_TARGETS_TO_BUILD:STRING="AArch64;ARM;WebAssembly;X86" \
			-DLLVM_CCACHE_BUILD:BOOL=FORCE_ON \
			-DLLVM_BUILD_LLVM_DYLIB:BOOL=FORCE_ON \
			-DLLVM_LINK_LLVM_DYLIB:BOOL=FORCE_ON
		;;
	esac

	ninja -C $LLVM_BUILD_PATH
fi

if [ ! -d "$(basename $ODIN_SOURCE)" ]; then
	git clone --branch="$ODIN_BRANCH" --depth=1 $ODIN_SOURCE
fi

cd "$(basename $ODIN_SOURCE)"

CXX="$LLVM_BIN_PATH/clang++" \
CXX_LD="$LLVM_BIN_PATH/lld" \
LLVM_CONFIG="$LLVM_BIN_PATH/llvm-config" \
./build_odin.sh
