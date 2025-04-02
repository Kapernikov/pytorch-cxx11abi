# CI/CD Pipelines for Dockerfiles

This repository contains CI/CD pipelines to build and deploy Docker images for CUDA-enabled environments with PyTorch and LibTorch pre-installed.

## Features
- Pre-built Docker images with **LibTorch / PyTorch (C++11 ABI)**
- CUDA 12.2.2-based environment
- CI/CD automation for reproducible builds

## Docker Images
The provided Dockerfiles build images that include:
- **PyTorch built from source** with CUDA support
- **LibTorch pre-installed** for C++ inference
- Essential dependencies for deep learning workflows

## CI/CD Pipeline
The pipeline automates:
1. **Build** - Compiles PyTorch and dependencies from source
2. **Test** - Runs basic validation checks
3. **Publish** - Pushes built images to a container registry

## Usage
Clone the repo and modify the pipeline as needed:
```sh
# Build the Docker image locally
DOCKER_BUILDKIT=1 docker build -t my-cuda-pytorch .
```

