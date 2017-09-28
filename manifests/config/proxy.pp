# == Class: patchwork::config::proxy
#
# This class sets up nginx + uwsgi for proxying patchwork
#
class patchwork::config::proxy inherits patchwork::params
{

    File {
        owner => $::os::params::adminuser,
        group => $::os::params::admingroup,
    }

    # Setup uwsgi
    file { [ '/etc/uwsgi', '/etc/uwsgi/sites' ]:
        ensure => 'directory',
        mode   => '0755',
    }

    file { '/etc/uwsgi/sites/patchwork.ini':
        ensure  => 'present',
        content => template('patchwork/patchwork.ini.erb'),
        mode    => '0755',
        require => File['/etc/uwsgi/sites'],
        notify  => Class['::patchwork::service'],
    }

    # Base nginx setup plus firewall and monit settings
    class { '::nginx':
        manage_config        => false,
        manage_monit         => true,
        manage_packetfilter  => true,
        purge_default_config => true,
        allow_address_ipv4   => 'anyv4',
        allow_address_ipv6   => 'anyv6',
    }

    # Patchwork-specific nginx configuration file
    file { '/etc/nginx/sites-enabled/patchwork.conf':
        ensure  => 'present',
        content => template('patchwork/patchwork.conf.erb'),
        mode    => '0644',
        require => Class['::nginx'],
        notify  => Class['::nginx::service'],
    }

}
