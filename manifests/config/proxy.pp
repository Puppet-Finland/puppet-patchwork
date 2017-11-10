# == Class: patchwork::config::proxy
#
# This class sets up nginx + uwsgi for proxying patchwork
#
class patchwork::config::proxy
(
    String  $server_name,
    Boolean $enable_rest_api,
            $sslcert_basename,
            $sslcert_bundlefile,
    String  $admin_allow_address_ipv4,
    String  $rest_allow_address_ipv4

) inherits patchwork::params
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

    # Setup SSL certificates
    sslcert::set { $sslcert_basename:
        bundlefile => $sslcert_bundlefile,
        embed_bundle => true,
    }

    # Base nginx setup plus firewall and monit settings
    class { '::nginx':
        manage_config        => false,
        manage_monit         => false,
        manage_packetfilter  => false,
        purge_default_config => true,
    }

    # Patchwork-specific nginx configuration file
    file { '/etc/nginx/sites-enabled/patchwork.conf':
        ensure  => 'present',
        content => template('patchwork/patchwork.conf.erb'),
        mode    => '0644',
        require => [ Class['::nginx'], Sslcert::Set[$sslcert_basename] ],
        notify  => Class['::nginx::service'],
    }

}
