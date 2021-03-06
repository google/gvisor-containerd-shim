#!/bin/bash

# A sample script for installing and configuring the gvisor-containerd-shim to
# use the untrusted workload extension.

set -ex

{ # Step 1: Create containerd config.toml
cat <<EOF | sudo tee /etc/containerd/config.toml
disabled_plugins = ["restart"]
[plugins.linux]
  shim = "/usr/local/bin/gvisor-containerd-shim"
  shim_debug = true
# Set to avoid port overlap on older versions of containerd where default is 10010.
[plugins.cri]
  stream_server_port = "10011"
[plugins.cri.containerd.untrusted_workload_runtime]
  runtime_type = "io.containerd.runtime.v1.linux"
  runtime_engine = "/usr/local/bin/runsc"
  runtime_root = "/run/containerd/runsc"
EOF
}

{ # Step 2: Restart containerd
sudo pkill containerd
sudo containerd -log-level debug &>/tmp/containerd-cri.log &
}
