# Script to download triton_kernels using Git sparse checkout
# This script is called by FetchContent during the download phase

if(NOT TRITON_KERNELS_SOURCE_DIR)
  message(FATAL_ERROR "TRITON_KERNELS_SOURCE_DIR must be defined")
endif()

if(NOT TRITON_KERNELS_TAG)
  message(FATAL_ERROR "TRITON_KERNELS_TAG must be defined")
endif()

# Create the source directory
file(MAKE_DIRECTORY "${TRITON_KERNELS_SOURCE_DIR}")

# Initialize git repository with sparse checkout
execute_process(
  COMMAND git init
  WORKING_DIRECTORY "${TRITON_KERNELS_SOURCE_DIR}"
  RESULT_VARIABLE GIT_INIT_RESULT
)

if(NOT GIT_INIT_RESULT EQUAL 0)
  message(FATAL_ERROR "Failed to initialize git repository")
endif()

# Add remote
execute_process(
  COMMAND git remote add origin https://github.com/triton-lang/triton.git
  WORKING_DIRECTORY "${TRITON_KERNELS_SOURCE_DIR}"
  RESULT_VARIABLE GIT_REMOTE_RESULT
)

if(NOT GIT_REMOTE_RESULT EQUAL 0)
  message(FATAL_ERROR "Failed to add git remote")
endif()

# Enable sparse checkout
execute_process(
  COMMAND git config core.sparseCheckout true
  WORKING_DIRECTORY "${TRITON_KERNELS_SOURCE_DIR}"
  RESULT_VARIABLE GIT_CONFIG_RESULT
)

if(NOT GIT_CONFIG_RESULT EQUAL 0)
  message(FATAL_ERROR "Failed to enable sparse checkout")
endif()

# Configure sparse checkout patterns
file(WRITE "${TRITON_KERNELS_SOURCE_DIR}/.git/info/sparse-checkout" "python/triton_kernels/*\n")

# Fetch with shallow clone
message(STATUS "Fetching triton_kernels from tag ${TRITON_KERNELS_TAG}...")
execute_process(
  COMMAND git fetch --depth=1 origin ${TRITON_KERNELS_TAG}
  WORKING_DIRECTORY "${TRITON_KERNELS_SOURCE_DIR}"
  RESULT_VARIABLE GIT_FETCH_RESULT
)

if(NOT GIT_FETCH_RESULT EQUAL 0)
  message(FATAL_ERROR "Failed to fetch from git repository")
endif()

# Checkout the tag
execute_process(
  COMMAND git checkout ${TRITON_KERNELS_TAG}
  WORKING_DIRECTORY "${TRITON_KERNELS_SOURCE_DIR}"
  RESULT_VARIABLE GIT_CHECKOUT_RESULT
)

if(NOT GIT_CHECKOUT_RESULT EQUAL 0)
  message(FATAL_ERROR "Failed to checkout tag ${TRITON_KERNELS_TAG}")
endif()

message(STATUS "Successfully downloaded triton_kernels using sparse checkout")
