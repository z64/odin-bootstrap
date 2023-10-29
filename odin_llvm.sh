#!/usr/bin/env sh

set -eux

CC="${CC:-clang}"
CXX="${CXX:-clang++}"
LD="${LD:-lld}"

CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}"
CMAKE_GENERATOR="${CMAKE_GENERATOR:-Unix Makefiles}"
LLVM_BRANCH="${LLVM_BRANCH:-llvmorg-17.0.3}"
LLVM_SOURCE="${LLVM_SOURCE:-https://github.com/llvm/llvm-project}"
ODIN_BRANCH="${ODIN_BRANCH:-master}"
ODIN_SOURCE="${ODIN_SOURCE:-https://github.com/odin-lang/Odin}"

OS_NAME="$(uname -s)"

if [ -e "$(command -v ninja)" ]; then
	CMAKE_GENERATOR="Ninja"
fi

#
# LLVM
#

LLVM_PATH="$PWD/llvm-project"
LLVM_SOURCE_PATH="$LLVM_PATH/llvm"

LLVM_BUILD_PATH="$LLVM_PATH/build"
LLVM_BIN_PATH="$LLVM_BUILD_PATH/bin"
LLVM_CONFIG="$LLVM_BIN_PATH/llvm-config"

if [ ! -d "$(basename $LLVM_SOURCE)" ]; then
	git clone --branch="$LLVM_BRANCH" --depth=1 $LLVM_SOURCE
fi

llvm_cmake() {
	cmake -Wno-dev -G "$CMAKE_GENERATOR" -B "$LLVM_BUILD_PATH" -S "$LLVM_SOURCE_PATH" \
		-DCMAKE_BUILD_TYPE:STRING="$CMAKE_BUILD_TYPE" \
		-DLLVM_ENABLE_PROJECTS:STRING="compiler-rt" \
		-DLLVM_TARGETS_TO_BUILD:STRING="AArch64;ARM;WebAssembly;X86" \
		-DLLVM_INCLUDE_TOOLS:BOOL=FORCE_ON \
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
	if [ ! -d "$LLVM_BUILD_PATH" ]; then
		mkdir -p "$LLVM_BUILD_PATH"
	fi

	if [ ! -f "$LLVM_BUILD_PATH/CMakeCache.txt" ]; then
		llvm_cmake $@

		if [ "$CMAKE_GENERATOR" = "Ninja" ]; then
			ninja -C $LLVM_BUILD_PATH
		else
			case "$OS_NAME" in
			Darwin)
				make -C $LLVM_BUILD_PATH -j$(sysctl -n hw.logicalcpu)
				;;
			FreeBSD|OpenBSD)
				make -C $LLVM_BUILD_PATH -j$(sysctl -n hw.ncpu)
				;;
			Linux)
				make -C $LLVM_BUILD_PATH -j$(grep -c "processor" /proc/cpuinfo)
				;;
			*)
				make -C $LLVM_BUILD_PATH
				;;
			esac
		fi
	fi
}

case "$OS_NAME" in
Darwin)
	# Darwin doesn't need static linking
	llvm_build \
		-DLLVM_BUILD_LLVM_C_DYLIB:BOOL=FORCE_ON \
		-DLLVM_BUILD_LLVM_DYLIB:BOOL=OFF \
		-DLLVM_LINK_LLVM_DYLIB:BOOL=OFF
	;;
Linux)
	llvm_build
	;;
*)
	echo "error: \"$OS_NAME\" not supported"
	exit 1
esac

#
# Odin
#

if [ ! -d "$(basename $ODIN_SOURCE)" ]; then
	git clone --branch="$ODIN_BRANCH" --depth=1 $ODIN_SOURCE
fi

cd "$(basename $ODIN_SOURCE)"

case "$OS_NAME" in
Linux)
	# We need to statically link Odin against LLVM
	CPPFLAGS="-DODIN_VERSION_RAW=\"dev-$(date +"%Y-%m")\""
	CXXFLAGS="-O3 -march=x86-64 -std=c++14"
	CXXFLAGS="$CXXFLAGS $($LLVM_CONFIG --cxxflags --ldflags --system-libs)"
	DISABLED_WARNINGS="-Wno-switch -Wno-macro-redefined -Wno-unused-value"
	LDFLAGS="-pthread -lm -lstdc++"
	LDFLAGS="$LDFLAGS $($LLVM_CONFIG --libfiles --libs aarch64 arm core native passes runtimedyld webassembly)"

	if [ -d ".git" ] && [ -n "$(command -v git)" ]; then
		GIT_SHA=$(git show --pretty='%h' --no-patch --no-notes HEAD)
		CPPFLAGS="$CPPFLAGS -DGIT_SHA=\"$GIT_SHA\""
	fi

	$CXX src/main.cpp src/libtommath.cpp $DISABLED_WARNINGS $CPPFLAGS $CXXFLAGS $LDFLAGS -o odin
	;;
*)
	# Use the normal build process for non-Linux platforms
	./build_odin.sh release
	;;
esac
