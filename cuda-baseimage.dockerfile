# NVIDIA CUDA Development Environment with PyTorch
# This Dockerfile creates a comprehensive CUDA-enabled environment with PyTorch built from source.
# Build process could take 10+ hours. Change MAX_JOBS for faster building time.
FROM nvidia/cuda:12.2.2-devel-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt
# apt packages ------------------------------------------------------------------------------------------------
RUN apt-get -y update && \
    apt-get -y install build-essential cmake curl git libeigen3-dev \
                       libjsoncpp-dev libtbb-dev liblz4-dev \
                       libyaml-cpp-dev wget zip python3 python3-pip python3-dev pybind11-dev && \
    pip install --upgrade pip && \
# some pip packages -------------------------------------------------------------------------------------------
    pip install numpy pyyaml typing_extensions future six requests dataclasses minio dash plotly pandas && \
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
    GLIBCXX_USE_CXX11_ABI=1 MAX_JOBS=2 USE_CUDA=1 USE_CUDNN=1 TORCH_CUDA_ARCH_LIST="8.0" python3 setup.py bdist_wheel && \
    pip install dist/torch-*.whl && \
    cd build && cmake --install . --prefix /usr/local && \
    # cleanup the source deps files
    cd / && rm -r /opt/deps
