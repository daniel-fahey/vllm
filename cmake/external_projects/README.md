# External Projects

This directory contains CMake configuration files for external projects that are fetched at build time using CMake's `FetchContent` module.

## Projects

### flashmla.cmake
Flash-MLA (Multi-Layer Attention) implementation.

### qutlass.cmake
QuTLASS - Quantization utilities using CUTLASS for CUDA kernels.
- **Repository**: https://github.com/IST-DASLab/qutlass.git
- **Environment Variable**: `QUTLASS_SRC_DIR` - Use local source directory instead of downloading

### triton_kernels.cmake
Triton kernels for high-performance MoE (Mixture of Experts) operations.
- **Repository**: https://github.com/triton-lang/triton.git
- **Default Version**: v3.5.0 (configurable via `TRITON_KERNELS_TAG`)
- **Location**: The `triton_kernels` Python package is in the `python/triton_kernels` subdirectory
- **Optimization**: Uses Git sparse checkout to fetch only the `python/triton_kernels` subdirectory, avoiding the entire Triton monorepo
- **Environment Variables**:
  - `TRITON_KERNELS_SRC_DIR` - Use local Triton source directory instead of downloading
  - `TRITON_KERNELS_TAG` - Override the default version tag (default: v3.5.0)

**Installation**: The triton_kernels Python package is automatically installed during the CMake configuration phase. If automatic installation fails, you can manually install it:
```bash
pip install -e <vllm-root>/.deps/triton_kernels-src/python/triton_kernels
```

**Note**: This is different from `conch-triton-kernels`, which is a separate PyPI package required for ROCm builds.

### vllm_flash_attn.cmake
vLLM flash attention implementation. Should be included last as it overwrites some CMake functions.

## Usage

These external projects are automatically included during the vLLM build process based on the target device:
- CUDA builds include: flashmla, qutlass, vllm_flash_attn
- CUDA and HIP builds include: triton_kernels

## Development

To use a local source directory for development:
```bash
export TRITON_KERNELS_SRC_DIR=/path/to/triton
# or
export QUTLASS_SRC_DIR=/path/to/qutlass

# Then build vLLM normally
pip install -e .
```
