# NVIDIA CUDA Development Environment with PyTorch (Python 3.12)
# This Dockerfile creates a comprehensive CUDA-enabled environment with PyTorch built from source.
# Build process could take 10+ hours. Change MAX_JOBS for faster building time.
FROM nvidia/cuda:12.2.2-devel-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt
# apt packages ------------------------------------------------------------------------------------------------
RUN apt-get -y update && \
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get -y update && \
    apt-get -y install build-essential cmake curl git libeigen3-dev \
                       libjsoncpp-dev libtbb-dev liblz4-dev \
                       libyaml-cpp-dev wget zip \
                       python3.12 python3.12-dev python3.12-venv \
                       pybind11-dev && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    python3.12 -m ensurepip && \
    python3.12 -m pip install --upgrade pip && \
# some pip packages -------------------------------------------------------------------------------------------
    python3.12 -m pip install --ignore-installed "numpy>=2.0" pyyaml typing_extensions future six requests dataclasses minio dash plotly pandas && \
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
    GLIBCXX_USE_CXX11_ABI=1 USE_NINJA=1 MAX_JOBS=2 USE_CUDA=1 USE_CUDNN=1 TORCH_CUDA_ARCH_LIST="8.0" python3.12 setup.py bdist_wheel && \
    python3.12 -m pip install dist/torch-*.whl && \
    cd build && cmake --install . --prefix /usr/local && \
    # cleanup the source deps files
    cd / && rm -r /opt/deps
