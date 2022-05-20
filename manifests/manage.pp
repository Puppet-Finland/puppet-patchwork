#
# @summary run patchwork's manage.py commands
#
class patchwork::manage inherits patchwork::params
{
  exec {
    default:
      cwd         => '/opt/patchwork',
      path        => '/bin:/usr/bin',
      refreshonly => true,
      subscribe   => [ Class['::patchwork::install'], File['production.py'] ],
    ;
    ['patchwork migrate']:
      user    => 'www-data',
      command => 'python3 manage.py migrate',
      require => File['production.py'],
    ;
    ['patchwork collectstatic']:
      user    => 'root',
      command => 'python3 manage.py collectstatic',
      require => Exec['patchwork migrate'],
    ;
    ['patchwork loaddata']:
      user    => 'www-data',
      command => 'python3 manage.py loaddata default_tags default_states',
      require => Exec['patchwork collectstatic'],
    ;
  }
}
