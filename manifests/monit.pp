#
# == Class: patchwork::monit
#
# Setup monit (for nginx)
#
class patchwork::monit inherits patchwork::params {
    include ::nginx::monit
}
