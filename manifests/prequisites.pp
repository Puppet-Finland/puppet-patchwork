# == Class: patchwork::prequisites
#
# This class install prequisites of patchwork
#
class patchwork::prequisites inherits patchwork::params
{
    include ::git

    # Basic requirements
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

    # Requirements for nginx + uwsgi proxy
    $proxy_packages = [ 'nginx-full', 'uwsgi', 'uwsgi-plugin-python3']
    ensure_packages($proxy_packages, {'ensure' => 'present'})

    # Requirements for postgresql
    include ::postgresql
    include ::postgresql::install::contrib
}
