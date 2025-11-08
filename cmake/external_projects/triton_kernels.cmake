#
# Triton Kernels - FetchContent integration for MoE operations
#
# This file fetches only the triton_kernels subdirectory from the Triton repository
# at build time using Git sparse checkout. This avoids vendoring ~7,800 lines of code
# and resolves UV package manager compatibility issues, while also avoiding downloading
# the entire Triton monorepo.
#
# The triton_kernels package provides high-performance MoE (Mixture of Experts)
# kernels and is used by vLLM for optimal performance on Hopper and Blackwell GPUs.
#
# See: https://github.com/vllm-project/vllm/issues/27672
#

include(FetchContent)

# Triton kernels version/tag to fetch
set(TRITON_KERNELS_TAG "v3.5.0" CACHE STRING "Triton repository tag to fetch")

# Support for local source directory (useful for development)
if(DEFINED ENV{TRITON_KERNELS_SRC_DIR})
  set(TRITON_KERNELS_SRC_DIR $ENV{TRITON_KERNELS_SRC_DIR})
endif()

if(TRITON_KERNELS_SRC_DIR)
  FetchContent_Declare(
    triton_kernels
    SOURCE_DIR ${TRITON_KERNELS_SRC_DIR}
  )
else()
  # Use a custom download script to perform sparse checkout
  # This only downloads the python/triton_kernels subdirectory instead of the entire monorepo
  FetchContent_Declare(
    triton_kernels
    DOWNLOAD_COMMAND
      ${CMAKE_COMMAND}
      -DTRITON_KERNELS_SOURCE_DIR=<SOURCE_DIR>
      -DTRITON_KERNELS_TAG=${TRITON_KERNELS_TAG}
      -P ${CMAKE_CURRENT_LIST_DIR}/../scripts/download_triton_kernels.cmake
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    UPDATE_COMMAND ""
  )
endif()

FetchContent_Populate(triton_kernels)

if(NOT triton_kernels_SOURCE_DIR)
  message(FATAL_ERROR "[TRITON_KERNELS] source directory could not be resolved.")
endif()

# The triton_kernels Python package is located in python/triton_kernels subdirectory
set(TRITON_KERNELS_PYTHON_DIR "${triton_kernels_SOURCE_DIR}/python/triton_kernels")

if(NOT EXISTS "${TRITON_KERNELS_PYTHON_DIR}/setup.py" AND
   NOT EXISTS "${TRITON_KERNELS_PYTHON_DIR}/pyproject.toml")
  message(FATAL_ERROR
    "[TRITON_KERNELS] Python package not found at ${TRITON_KERNELS_PYTHON_DIR}. "
    "Expected setup.py or pyproject.toml in this directory.")
endif()

message(STATUS "[TRITON_KERNELS] Triton source is available at ${triton_kernels_SOURCE_DIR}")
message(STATUS "[TRITON_KERNELS] triton_kernels Python package at ${TRITON_KERNELS_PYTHON_DIR}")

# Install triton_kernels Python package if Python executable is available
if(VLLM_PYTHON_EXECUTABLE)
  message(STATUS "[TRITON_KERNELS] Installing triton_kernels Python package...")

  # Install the package in editable mode so it uses the fetched source
  execute_process(
    COMMAND ${VLLM_PYTHON_EXECUTABLE} -m pip install -e "${TRITON_KERNELS_PYTHON_DIR}"
    RESULT_VARIABLE TRITON_KERNELS_INSTALL_RESULT
    OUTPUT_VARIABLE TRITON_KERNELS_INSTALL_OUTPUT
    ERROR_VARIABLE TRITON_KERNELS_INSTALL_ERROR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
  )

  if(TRITON_KERNELS_INSTALL_RESULT EQUAL 0)
    message(STATUS "[TRITON_KERNELS] Successfully installed triton_kernels")
  else()
    message(WARNING
      "[TRITON_KERNELS] Failed to install triton_kernels automatically. "
      "You can manually install it with:\n"
      "  ${VLLM_PYTHON_EXECUTABLE} -m pip install -e ${TRITON_KERNELS_PYTHON_DIR}\n"
      "Error: ${TRITON_KERNELS_INSTALL_ERROR}")
  endif()
else()
  message(WARNING
    "[TRITON_KERNELS] VLLM_PYTHON_EXECUTABLE not set. "
    "triton_kernels will not be installed automatically.")
endif()
