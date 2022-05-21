#
# == Class: patchwork::params
#
# Defines some variables based on the operating system
#
class patchwork::params {

    case $::osfamily {
        'Debian': {
          # According to puppet-nginx documentation and practical testing
          # nginx version needs to be defined in ::nginx class to get an
          # an idempotent configuration that does not change on the second
          # Puppet run.
          $nginx_version = $::lsbdistcodename ? {
            'focal' => '1.20.2',
            default => '1.20.2',
          }
        }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }
}
