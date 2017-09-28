#
# == Class: patchwork::config
#
# Configure patchwork and its dependencies
#
class patchwork::config
(
    $secret_key,
    $default_from_email,
    $db_password
)
{
    # Patchwork will not work without a database
    class { '::patchwork::config::postgresql':
        db_password => $db_password,
    }

    File {
        owner => $::os::params::adminuser,
        group => $::os::params::admingroup,
    }

    # Patchwork configuration file
    file { 'production.py':
        ensure  => 'present',
        path    => '/opt/patchwork/patchwork/settings/production.py',
        content => template('patchwork/production.py.erb'),
        notify  => Exec['patchwork manage.py'],
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
    class { '::patchwork::config::proxy': }

}
