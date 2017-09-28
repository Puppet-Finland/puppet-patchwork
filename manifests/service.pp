#
# == Class: patchwork::service
#
# Manage the patchwork service
#
class patchwork::service inherits patchwork::params {

    # This class handles "systemctl daemon-reload"
    include ::systemd::service

    # Remove init script as suggested by patchwork documentation
    file { '/etc/init.d/uwsgi':
        ensure  => 'absent',
        require => Class['::patchwork::prequisites'],
    }

    # Setup a systemd unit file for uwsgi
    file { '/etc/systemd/system/uwsgi.service':
        ensure  => 'present',
        content => template('patchwork/uwsgi.service.erb'),
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0644',
        require => Class['::patchwork::config::proxy'],
        notify  => [ Class['::systemd::service'], Service['uwsgi'] ],
    }

    # Ensure that uwsgi is running
    service { 'uwsgi':
        ensure  => 'running',
        enable  => true,
        require => File['/etc/systemd/system/uwsgi.service'],
    }


}
