# == Class: patchwork::prequisites
#
# This class install prequisites of patchwork
#
class patchwork::prequisites
(
    $db_password

) inherits patchwork::params
{
    include ::git

    $python_packages = ['python3-dev',
                        'python3-virtualenv',
                        'python3-pip',
                        'python3-psycopg2',
                        'python3-django',
                        'python3-djangorestframework',
                        'python3-django-filters' ]

    # By using ensure_packages the risk for stepping on toes of other modules is 
    # reduced greatly
    ensure_packages($python_packages, {'ensure' => 'present'})

    include ::postgresql
    include ::postgresql::install::contrib

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
