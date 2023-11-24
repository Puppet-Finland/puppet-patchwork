# @summary install prequisites for Patchwork
#
class patchwork::prerequisites inherits patchwork::params
{
  # Basic requirements
  $python_packages = ['python3-dev',
                      'python3-psycopg2',
                      'python3-django',
                      'python3-djangorestframework',
                      'python3-django-filters' ]

  # By using ensure_packages the risk for stepping on toes of other
  # modules is reduced greatly
  stdlib::ensure_packages($python_packages, {'ensure' => 'present'})

  # Ensure that "python" command is available
  stdlib::ensure_packages('python-is-python3', {'ensure' => 'present'})

  # POSIX extended ACLs are needed for fine-grained access control to
  # Patchwork's production.py (config file)
  stdlib::ensure_packages('acl', {'ensure' => 'present'})
}
