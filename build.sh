#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Define variables for versions and paths
WASI_SDK_VERSION="24.0"
WASI_SDK_ARCHIVE="wasi-sdk-${WASI_SDK_VERSION}-x86_64-linux.tar.gz"
WASI_SDK_URL="https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_SDK_VERSION%.*}/${WASI_SDK_ARCHIVE}"
WASI_SDK_DIR="/tmp/wasi-sdk"
UTILITIES_DIR="./utilities"

# Download and extract wasi-sdk if not already present
if [ ! -d "$WASI_SDK_DIR" ]; then
    echo "Downloading wasi-sdk"
    curl -sSL "$WASI_SDK_URL" -o "$WASI_SDK_ARCHIVE"
    echo "Extracting wasi-sdk"
    tar -xzf "$WASI_SDK_ARCHIVE"
    mv "wasi-sdk-${WASI_SDK_VERSION}-x86_64-linux" "$WASI_SDK_DIR"
    echo "Cleaning up downloaded archive"
    rm -f "$WASI_SDK_ARCHIVE"
else
    echo "wasi-sdk already installed at $WASI_SDK_DIR"
fi

export PATH="$WASI_SDK_DIR/bin:$PATH"

echo "Building the project"

# Compilation options
CLANG="$WASI_SDK_DIR/bin/clang"
SYSROOT="--sysroot $WASI_SDK_DIR/share/wasi-sysroot"
CFLAGS="-DPOLYBENCH_TIME -D_WASI_EMULATED_PROCESS_CLOCKS"
INCLUDES="-I$UTILITIES_DIR"

# List of benchmarks
BENCHMARKS=(
    "datamining/correlation/correlation"
    "datamining/covariance/covariance"
    "linear-algebra/kernels/2mm/2mm"
    "linear-algebra/kernels/3mm/3mm"
    "linear-algebra/kernels/atax/atax"
    "linear-algebra/kernels/bicg/bicg"
    "linear-algebra/kernels/doitgen/doitgen"
    "linear-algebra/kernels/mvt/mvt"
    "linear-algebra/blas/gemver/gemver"
    #ADD MORE BENCHMARKS HERE
)

# Compile each benchmark
for BENCH in "${BENCHMARKS[@]}"; do
    SRC="$BENCH.c"
    OUT="$BENCH.wasm"
    echo "Building $SRC -> $OUT"
    $CLANG $SYSROOT $CFLAGS $INCLUDES -o "$OUT" "$UTILITIES_DIR/polybench.c" "$SRC"
done

echo "Build completed successfully."