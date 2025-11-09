# Installing triton_kernels with UV

## Overview

The `triton_kernels` package provides high-performance MoE (Mixture of Experts) kernels and is the most performant option for running models with MoE layers on NVIDIA GPUs.

## The Challenge

`triton_kernels` is located in a subdirectory (`python/triton_kernels`) of the [Triton repository](https://github.com/triton-lang/triton), not at the root. This creates installation challenges:

- **pip**: Cannot handle git subdirectory dependencies in `install_requires`
- **UV**: Handles git subdirectory dependencies perfectly via `[tool.uv.sources]`

## Installation Methods

### For UV Users (Recommended)

vLLM recommends using UV for installation. With UV, `triton_kernels` is automatically installed:

```bash
uv pip install vllm
```

The `[tool.uv.sources]` configuration in `pyproject.toml` tells UV to fetch `triton_kernels` from the Triton repository automatically.

### For pip Users

pip cannot automatically install git subdirectory dependencies. You need to install `triton_kernels` manually:

```bash
# Install vLLM
pip install vllm

# Manually install triton_kernels
pip install "git+https://github.com/triton-lang/triton.git@v3.5.0#subdirectory=python/triton_kernels"
```

### Verification

Check if `triton_kernels` is installed:

```python
from vllm.utils.import_utils import has_triton_kernels

if has_triton_kernels():
    print("✓ triton_kernels is available")
else:
    print("✗ triton_kernels is not installed")
    print("Install with: pip install 'git+https://github.com/triton-lang/triton.git@v3.5.0#subdirectory=python/triton_kernels'")
```

## Why This Approach?

### UV-Specific Configuration

vLLM uses `[tool.uv.sources]` in `pyproject.toml` to specify where UV should fetch `triton_kernels`:

```toml
[tool.uv.sources]
triton-kernels = {
    git = "https://github.com/triton-lang/triton",
    subdirectory = "python/triton_kernels",
    tag = "v3.5.0"
}
```

This works because:
- ✅ UV supports git subdirectory dependencies
- ✅ UV is vLLM's recommended installation method
- ✅ No vendoring needed (~7,800 lines of code avoided)
- ✅ Precise version control via git tags
- ✅ Enables reproducible builds

### pip Limitations

pip cannot use `[tool.uv.sources]` (it's UV-specific) and rejects git URLs in `install_requires`. This is why pip users must install manually.

## Optional Dependency

`triton_kernels` is **optional**. vLLM will fall back to other MoE implementations if it's not installed:

- Marlin kernels
- Standard implementations
- ROCm uses `conch-triton-kernels` instead

However, for best performance on NVIDIA Hopper and Blackwell GPUs with MoE models, `triton_kernels` is recommended.

## Troubleshooting

### UV users: package not found

Make sure you're using a recent version of UV:

```bash
uv self update
uv --version  # Should be 0.5.0 or later
```

### pip users: import fails

If you installed vLLM with pip and get `ModuleNotFoundError: No module named 'triton_kernels'`:

```bash
pip install "git+https://github.com/triton-lang/triton.git@v3.5.0#subdirectory=python/triton_kernels"
```

### ROCm builds

ROCm builds use `conch-triton-kernels` instead, which is automatically installed from PyPI. You don't need to install `triton_kernels` separately for ROCm.
