#!/bin/bash

# A sample script for installing and configuring the gvisor-containerd-shim to
# use the containerd runtime handler. 

set -ex

{ # Step 1: Create containerd config.toml
cat <<EOF | sudo tee /etc/containerd/config.toml
disabled_plugins = ["restart"]
[plugins.linux]
  shim = "/usr/local/bin/gvisor-containerd-shim"
  shim_debug = true
[plugins.cri.containerd.runtimes.runsc]
  runtime_type = "io.containerd.runtime.v1.linux"
  runtime_engine = "/usr/local/bin/runsc"
  runtime_root = "/run/containerd/runsc"
EOF
}

{ # Step 2: Restart containerd
sudo pkill containerd
sudo containerd -log-level debug &> /tmp/containerd-cri.log &
}
