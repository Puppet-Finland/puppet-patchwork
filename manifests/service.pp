#
# == Class: patchwork::service
#
# Manage the patchwork service
#
class patchwork::service
(
    $imap_username

) inherits patchwork::params
{
    # This class handles "systemctl daemon-reload"
    include ::systemd::systemctl::daemon_reload

    # Remove init script as suggested by patchwork documentation
    file { '/etc/init.d/uwsgi':
        ensure  => 'absent',
        require => Class['::patchwork::prequisites'],
    }

    File {
        ensure  => 'present',
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0644',
    }

    # Setup a systemd unit file for uwsgi
    file { '/etc/systemd/system/uwsgi.service':
        content => template('patchwork/uwsgi.service.erb'),
        require => Class['::patchwork::config::proxy'],
        notify  => [ Class['::systemd::systemctl::daemon_reload'], Service['uwsgi'] ],
    }

    # Setup a systemd unit file for getmail
    file { '/etc/systemd/system/getmail.service':
        content => template('patchwork/getmail.service.erb'),
        notify  => [ Class['::systemd::systemctl::daemon_reload'], Service['getmail'] ],
    }

    # Ensure that uwsgi and getmail are running
    Service {
        ensure  => 'running',
        enable  => true,
    }

    service { 'uwsgi':
        require => File['/etc/systemd/system/uwsgi.service'],
    }

    service { 'getmail':
        require => File['/etc/systemd/system/getmail.service'],
    }
}
