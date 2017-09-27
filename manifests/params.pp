#
# == Class: patchwork::params
#
# Defines some variables based on the operating system
#
class patchwork::params {

    case $::osfamily {
        'Debian': {
            # TODO
        }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }
}
