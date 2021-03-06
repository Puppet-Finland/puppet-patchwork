#
# == Class: patchwork::config::getmail
#
# Setup getmail
#
class patchwork::config::getmail
(
    String  $imap_server,
    Integer $imap_port,
    String  $imap_username,
    String  $imap_password,
    Variant[String,Array[String]] $mailboxes

) inherits patchwork::params
{

    # Keyword ALL is a special case that can't be a tuple in the resulting 
    # getmail4 config file
    if $mailboxes == 'ALL' {
        $all_mailboxes = true
    } else {
        $l_mailboxes = any2array($mailboxes)
    }

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

    # We need an empty mboxrd file or getmail will fail to start
    file { '/var/spool/mail/nobody':
        ensure => 'present',
        owner  => 'nobody',
        group  => 'nogroup',
        mode   => '0644',
    }
}
