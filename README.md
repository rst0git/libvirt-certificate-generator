# Libvirt TLS Certificate Generation Scripts

This repository contains scripts to automate the generation of libvirt server and client TLS certificates.
All steps are described in https://wiki.libvirt.org/page/TLSSetup

Dependencies: `gnutls-utils`

## Usage:

1. Modify the following template files. In particular, make sure that the `cn` value corresponds to a correct hostname.

- `certificate_authority_template.info`
- `client_template.info`
- `host1_server_template.info`
- `host2_server_template.info`

2. Generate certificates

```bash
make
```
