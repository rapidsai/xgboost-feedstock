#!/bin/bash

set -exuo pipefail

mkdir -p build-target

if [[ ${cuda_compiler_version} != "None" ]]; then
    GPU_COMPUTE="60;70;75;80;86;90"
    export CMAKE_ARGS="-DUSE_CUDA=ON -DUSE_NCCL=ON -DBUILD_WITH_SHARED_NCCL=ON -DGPU_COMPUTE_VER=${GPU_COMPUTE} ${CMAKE_ARGS}"
fi

# Limit number of threads used to avoid hardware oversubscription
if [[ "${target_platform}" == "linux-aarch64" ]] || [[ "${target_platform}" == "linux-ppc64le" ]]; then
    export CMAKE_BUILD_PARALLEL_LEVEL=6
fi

pushd build-target

cmake ${CMAKE_ARGS} \
      -G "Ninja" \
      -D CMAKE_BUILD_TYPE:STRING="Release" \
      -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
      -D CMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
      -D USE_CUDA:BOOL=ON \
      -D BUILD_WITH_CUDA_CUB:BOOL="ON" \
      -D CMAKE_CUDA_COMPILER:PATH="${CUDA_HOME}/bin/nvcc" \
      -D CMAKE_CUDA_HOST_COMPILER:PATH="${CXX}" \
      -D CUDA_USE_STATIC_CUDA_RUNTIME:BOOL=OFF \
      -D CUDA_PROPAGATE_HOST_FLAGS:BOOL=OFF \
      -D CMAKE_CXX_STANDARD:STRING="17" \
      -D CMAKE_CUDA_FLAGS:STRING="" \
      -D USE_NCCL:BOOL=ON \
      -D NCCL_ROOT:PATH="${PREFIX}" \
      -D NCCL_INCLUDE_DIR:PATH="${PREFIX}/include" \
      -D BUILD_WITH_SHARED_NCCL:BOOL=ON \
      -D USE_CUDF:BOOL=ON \
      -D CUDF_ROOT:PATH="${PREFIX}" \
      -D CUDF_INCLUDE_DIR:PATH="${PREFIX}/include" \
      -D PLUGIN_RMM=ON \
      -D RMM_ROOT="${PREFIX}" \
      "${SRC_DIR}"
cmake --build . --config Release
popd
