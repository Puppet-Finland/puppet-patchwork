# == Class: patchwork
#
# This class sets up patchwork
#
# Currently functionality is limited to installing or removing the package.
#
# == Parameters
#
# [*manage*]
#   Whether to manage patchwork using Puppet. Valid values are true (default) 
#   and false.
#
# == Authors
#
# Samuli Seppänen <samuli@openvpn.net>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class patchwork
(
    Boolean $manage = true,
            $secret_key,
            $allowed_hosts = '*',
            $default_from_email,
            $db_password

) inherits patchwork::params
{

if $manage {

    include ::patchwork::prequisites
    include ::patchwork::install

    class { '::patchwork::config':
        secret_key         => $secret_key,
        allowed_hosts      => $allowed_hosts,
        default_from_email => $default_from_email,
        db_password        => $db_password
    }

    include ::patchwork::service
}
}
