#!/bin/bash

# Runs end-to-end tests for gvisor-containerd-shim to test the use of runtime
# handler. This should work on containerd 1.2+

# This is meant to be run in a VM as it makes a fairly invasive install of
# containerd.

set -ex

# Install containerd
. ./test/e2e/containerd-install.sh

# Install gVisor
. ./test/e2e/runsc-install.sh

# Install gvisor-containerd-shim
. ./test/e2e/shim-install.sh

# Test installation/configuration
. ./test/e2e/runtime-handler/install.sh

# Install crictl
. ./test/e2e/crictl-install.sh

# Test usage
. ./test/e2e/runtime-handler/usage.sh

# Run a container in the sandbox
. ./test/e2e/run-container.sh

# Validate the pod and container
. ./test/e2e/validate.sh
