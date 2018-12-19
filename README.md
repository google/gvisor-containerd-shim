# gvisor-containerd-shim

gvisor-containerd-shim is a containerd shim for [gVisor](https://github.com/google/gvisor/). It implements the containerd v1 shim API. It can be used as a drop-in replacement for [containerd-shim](https://github.com/containerd/containerd/tree/master/cmd/containerd-shim) (though containerd-shim must still be installed). It allows the use of both gVisor (runsc) and normal containers in the same containerd installation by deferring to the runc shim if the desired runtime engine is not runsc.

## Requirements

- gvisor (runsc) >= a2ad8fe
- containerd, containerd-shim >= 1.1

## Installation

- [Untrusted Workload Quick Start (containerd >=1.1)](docs/untrusted-workload-quickstart.md)
- [Runtime Handler Quick Start (containerd >=1.2)](docs/runtime-handler-quickstart.md)

# Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
