#
# == Class: patchwork::config::getmail
#
# Setup getmail
#
class patchwork::config::getmail
(
    $imap_server,
    $imap_port,
    $imap_username,
    $imap_password

) inherits patchwork::params
{

    file { '/etc/getmail':
        ensure => 'directory',
        owner  => $::os::params::adminuser,
        group  => $::os::params::admingroup,
        mode   => '0755',
    }

    file { "/etc/getmail/${imap_username}":
        ensure  => 'directory',
        owner   => 'nobody',
        group   => 'nogroup',
        mode    => '0755',
        require => File['/etc/getmail'],
    }

    file { "/etc/getmail/${imap_username}/getmailrc":
        ensure  => 'present',
        content => template('patchwork/getmailrc.erb'),
        owner   => 'nobody',
        group   => 'nogroup',
        mode    => '0644',
        require => File["/etc/getmail/${imap_username}"],
    }
}
