# PyTorch
# This Dockerfile creates a comprehensive environment with PyTorch built from source.
# Build process could take 10+ hours. Change MAX_JOBS for faster building time.
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt
# Intel oneAPI APT repo (for MKL) -----------------------------------------------------------------------------
RUN apt-get -y update && \
    apt-get -y install --no-install-recommends ca-certificates curl gnupg && \
    curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
        | gpg --dearmor -o /usr/share/keyrings/oneapi-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
        > /etc/apt/sources.list.d/oneAPI.list
# MKL env (set before PyTorch build so cmake's FindMKL picks it up) -------------------------------------------
ENV MKLROOT=/opt/intel/oneapi/mkl/latest
ENV LD_LIBRARY_PATH=${MKLROOT}/lib/intel64
# apt packages ------------------------------------------------------------------------------------------------
RUN apt-get -y update && \
    apt-get -y install build-essential cmake curl git libeigen3-dev \
                       libjsoncpp-dev libtbb-dev liblz4-dev \
                       libyaml-cpp-dev wget zip python3 python3-pip python3-dev pybind11-dev \
                       intel-oneapi-mkl-devel && \
    pip install --upgrade pip setuptools wheel "cmake>=3.27,<4" && \
# some pip packages -------------------------------------------------------------------------------------------
    pip install numpy==1.26.* pyyaml typing_extensions future six requests dataclasses minio dash plotly pandas && \
# compiled from source dependencies ---------------------------------------------------------------------------
# lastool  ---------------------------------------------------------------------------------------------------
    mkdir /opt/build && mkdir /opt/deps && cd /opt/deps &&  \
    git clone https://github.com/LAStools/LAStools && \
    cd LAStools && git checkout 9bdc92c && cmake -DCMAKE_BUILD_TYPE=Release . && make -j install && \
# PyTorch, with cuda support ---------------------------------------------------------------------------------
# options : MAX_JOBS core build. c++11 abi. TORCH_CUDA_ARCH_LIST controls which gpu can be used
    cd /opt/deps && \
    git clone --depth 1  --recursive https://github.com/pytorch/pytorch && \
    cd pytorch && \
    git submodule sync && \
    git submodule update --init --recursive && \
    _GLIBCXX_USE_CXX11_ABI=1 MAX_JOBS=4 USE_NINJA=1 \
        BLAS=MKL MKLROOT=${MKLROOT} USE_MKLDNN=1 \
        python3 setup.py bdist_wheel && \
    pip install dist/torch-*.whl && \
    python3 -c "import torch; print(torch.__config__.show())" | tee /opt/torch_config.txt && \
    grep -q 'USE_MKL=ON' /opt/torch_config.txt && \
    grep -qi 'BLAS_INFO=mkl' /opt/torch_config.txt && \
    cd build && cmake --install . --prefix /usr/local && \
# cleanup the source deps files
    cd / && rm -r /opt/deps
