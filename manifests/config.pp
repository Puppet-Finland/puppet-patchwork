#
# == Class: patchwork::config
#
# Configure patchwork and its dependencies
#
class patchwork::config
(
    String                $secret_key,
    Variant[String,Array] $allowed_hosts,
    String                $default_from_email,
    Hash[String,String]   $admins,
                          $imap_server,
                          $imap_port,
                          $imap_username,
                          $imap_password,
                          $sslcert_basename,
                          $sslcert_bundlefile,
                          $db_password,
                          $admin_allow_address_ipv4

) inherits patchwork::params
{
    # Patchwork will not work without a database
    class { '::patchwork::config::postgresql':
        db_password => $db_password,
    }

    File {
        owner => $::os::params::adminuser,
        group => $::os::params::admingroup,
    }

    # This is required to allow both String and Array parameters as the 
    # validate_* functions are deprecated
    include ::stdlib
    $l_allowed_hosts = flatten(any2array($allowed_hosts))

    # Patchwork configuration file
    file { 'production.py':
        ensure  => 'present',
        path    => '/opt/patchwork/patchwork/settings/production.py',
        content => template('patchwork/production.py.erb'),
        notify  => Exec['patchwork manage.py'],
    }

    # Force use of Python 3 in manage.py 
    file_line { 'manage.py-python3':
        ensure => 'present',
        path   => '/opt/patchwork/manage.py',
        line   => '#!/usr/bin/env python3',
        match  => '^#!/usr/bin/env python$',
    }

    # Force use of Python 3 in parsemail.sh
    file_line { 'parsemail.sh-python':
        ensure => 'present',
        path   => '/opt/patchwork/patchwork/bin/parsemail.sh',
        line   => '    PW_PYTHON=python3',
        match  => '^    PW_PYTHON=python2$',
    }

    # Fix bug in patchwork packaging on Ubuntu 16.04 which prevents "python3 
    # manage.py collectstatic" from working
    file { '/usr/lib/python3/dist-packages/rest_framework/static/rest_framework/img/grid.png':
        ensure => 'present',
        source => 'file:/usr/share/doc/python3-djangorestframework/img/grid.png',
    }

    # Create the database, copy static files, add fixtures. This exec gets run 
    # in the following cases:
    #
    # - When the setting file changes
    # - When the local patchwork Git clone changes (e.g. due to an upgrade)
    #
    exec { 'patchwork manage.py':
        command     => 'python3 manage.py migrate && python3 manage.py collectstatic --noinput && python3 manage.py loaddata default_tags default_states',
        cwd         => '/opt/patchwork',
        path        => '/bin:/usr/bin',
        refreshonly => true,
    }

    # Patchwork is configured so we can setup nginx and uwsgi
    class { '::patchwork::config::proxy':
        sslcert_basename         => $sslcert_basename,
        sslcert_bundlefile       => $sslcert_bundlefile,
        admin_allow_address_ipv4 => $admin_allow_address_ipv4,
    }

    # Receive mail locally using getmail
    class { '::patchwork::config::getmail':
        imap_server   => $imap_server,
        imap_port     => $imap_port,
        imap_username => $imap_username,
        imap_password => $imap_password,
    }
}
