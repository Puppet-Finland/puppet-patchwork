# == Class: patchwork::config::postgresql
#
# This class install config::postgresql of patchwork
#
class patchwork::config::postgresql
(
    $db_password

) inherits patchwork::params
{
    Exec {
        user => $::postgresql::params::daemon_user,
        path => '/bin:/usr/bin',
    }

    # Create database and users. While usings Exec is not the most pretty
    # approach, it is simple and it works. GRANTs are done using a real
    # provider, though.
    #
    exec { 'create patchwork database':
        command => 'createdb patchwork',
        unless  => 'psql -c "\l"|grep -E \'^ patchwork \'',
    }

    # Adapted from puppetlabs/postgresql define ::postgresql::server::role
    #
    $password_hash = postgresql_password('patchwork', $db_password)

    postgresql_psql { 'CREATE ROLE patchwork ENCRYPTED PASSWORD ****':
        command     => "CREATE ROLE patchwork ENCRYPTED PASSWORD '\$NEWPGPASSWD' LOGIN",
        environment => "NEWPGPASSWD=${password_hash}",
        unless      => "SELECT 1 FROM pg_roles WHERE rolname = 'patchwork'",
    }
}