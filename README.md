# patchwork

A Puppet module for managing patchwork

# Module usage

Install patchwork using Hiera:

    classes:
        - patchwork

For details, see

* [Class: patchwork](manifests/init.pp)

# Dependencies

See [metadata.json](metadata.json).

# Operating system support

This module has been tested on

* Ubuntu 16.04

Adding support for other *NIX-style operating systems should be fairly 
straightforward.

For details see [params.pp](manifests/params.pp).

# TODO

* Automatically load postgresql grants
* Make the module less Ubuntu-specific
* Allow defining the installation directory (hardcoded to /opt/patchwork)
