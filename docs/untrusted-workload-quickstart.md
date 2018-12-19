# Untrusted Workload Quickstart

This document describes how to install and run the `gvisor-containerd-shim`
using the untrusted workload CRI extension. This requires containerd 1.1 or
later.

*Note: The untrusted workload CRI extension is deprecated by containerd. If you
are using containerd 1.2, please consider using runtime handler.*

## Install
 
### Install gvisor-containerd-shim

1. Download the latest release of the `gvisor-containerd-shim`. See the
   [releases page](https://github.com/google/gvisor-containerd-shim/releases)

[embedmd]:# (scripts/shim-install.sh shell /{ # Step 1/ /^}/)
```shell
{ # Step 1: Download gvisor-containerd-shim
wget -O gvisor-containerd-shim $(wget -qO - https://api.github.com/repos/google/gvisor-containerd-shim/releases | grep -oP '(?<="browser_download_url": ")https://[^"]*' | head -1)
chmod +x gvisor-containerd-shim
}
```

2. Copy the binary to the desired directory:

[embedmd]:# (scripts/shim-install.sh shell /{ # Step 2/ /^}/)
```shell
{ # Step 2: Copy the binary to the desired directory
mv gvisor-containerd-shim-* /usr/local/bin/gvisor-containerd-shim
}
```

3. Create the configuration for the gvisor shim in
   `/etc/containerd/gvisor-containerd-shim.yaml`:

[embedmd]:# (scripts/shim-install.sh shell /{ # Step 3/ /^}/)
```shell
{ # Step 3: Create the gvisor-containerd-shim.yaml
cat <<EOF | sudo tee /etc/containerd/gvisor-containerd-shim.yaml
# This is the path to the default runc containerd-shim.
runc_shim = "/usr/local/bin/containerd-shim"
EOF
}
```

### Configure containerd

1. Update `/etc/containerd/config.toml`. Be sure to update the path to
   `gvisor-containerd-shim` and `runsc` if necessary:

[embedmd]:# (scripts/untrusted-workload-install.sh shell /{ # Step 1/ /^}/)
```shell
{ # Step 1: Create containerd config.toml
cat <<EOF | sudo tee /etc/containerd/config.toml
disabled_plugins = ["restart"]
[plugins.linux]
  shim = "/usr/local/bin/gvisor-containerd-shim"
  shim_debug = true
[plugins.cri.containerd.untrusted_workload_runtime]
  runtime_type = "io.containerd.runtime.v1.linux"
  runtime_engine = "/usr/local/bin/runsc"
  runtime_root = "/run/containerd/runsc"
EOF
}
```

2. Restart `containerd`

[embedmd]:# (scripts/untrusted-workload-install.sh shell /{ # Step 2/ /^}/)
```shell
{ # Step 2: Restart containerd
sudo systemctl restart containerd
}
```

## Usage

You can run containers in gVisor via containerd's CRI.

### Install crictl

1. Download and install the crictl binary:

[embedmd]:# (scripts/crictl-install.sh shell /{ # Step 1/ /^}/)
```shell
{ # Step 1: Download crictl
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.13.0/crictl-v1.13.0-linux-amd64.tar.gz
tar xf crictl-v1.13.0-linux-amd64.tar.gz
sudo mv crictl /usr/local/bin
}
```

2. Write the crictl configuration file

[embedmd]:# (scripts/crictl-install.sh shell /{ # Step 2/ /^}/)
```shell
{ # Step 2: Configure crictl
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
EOF
}
```

### Create the nginx Sandbox in gVisor

1. Pull the nginx image

[embedmd]:# (scripts/untrusted-workload-usage.sh shell /{ # Step 1/ /^}/)
```shell
{ # Step 1: Pull the nginx image
sudo crictl pull nginx
}
```

2. Create the sandbox creation request

[embedmd]:# (scripts/untrusted-workload-usage.sh shell /{ # Step 2/ /^EOF\n}/)
```shell
{ # Step 2: Create sandbox.json
$ cat <<EOF | tee sandbox.json
{
    "metadata": {
        "name": "nginx-sandbox",
        "namespace": "default",
        "attempt": 1,
        "uid": "hdishd83djaidwnduwk28bcsb"
    },
    "annotations": {
      "io.kubernetes.cri.untrusted-workload": "true"
    },
    "linux": {
    },
    "log_directory": "/tmp"
}
EOF
}
```

3. Create the pod in gVisor

[embedmd]:# (scripts/untrusted-workload-usage.sh shell /{ # Step 3/ /^}/)
```shell
{ # Step 3: Create the sandbox
SANDBOX_ID=$(sudo crictl runp sandbox.json)
}
```

### Run the nginx Container in the Sandbox

1. Create the nginx container creation request

[embedmd]:# (scripts/run-container.sh shell /{ # Step 1/ /^EOF\n}/)
```shell
{ # Step 1: Create nginx container config
$ cat <<EOF | tee container.json
{
  "metadata": {
      "name": "nginx"
    },
  "image":{
      "image": "nginx"
    },
  "log_path":"nginx.0.log",
  "linux": {
  }
}
EOF
}
```

2. Create the nginx container

[embedmd]:# (scripts/run-container.sh shell /{ # Step 2/ /^}/)
```shell
{ # Step 2: Create nginx container
CONTAINER_ID=$(sudo crictl create ${SANDBOX_ID} container.json sandbox.json)
}
```

3. Start the nginx container

[embedmd]:# (scripts/run-container.sh shell /{ # Step 3/ /^}/)
```shell
{ # Step 3: Start nginx container
sudo crictl start ${CONTAINER_ID}
}
```
