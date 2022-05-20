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
  ensure_packages($python_packages, {'ensure' => 'present'})
}
