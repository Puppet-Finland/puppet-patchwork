#
# @summary set up uwsgi for Patchwork
#
class patchwork::uwsgi inherits patchwork::params
{
  # Setup uwsgi
  package { [ 'uwsgi', 'uwsgi-plugin-python3']:
    ensure => 'present',
  }

  file {
    default:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    ;
    ['/run/uwsgi']:
      require => Package['uwsgi'],
    ;
    ['/run/uwsgi/app']:
      require => File['/run/uwsgi'],
    ;
    ['/run/uwsgi/app/patchwork']:
      require => File['/run/uwsgi/app'],
      owner   => 'www-data',
      group   => 'www-data',
    ;
  }

  file { '/etc/uwsgi/apps-enabled/patchwork.ini':
    ensure  => 'present',
    content => template('patchwork/patchwork.ini.erb'),
    mode    => '0644',
    require => [ Package['uwsgi'], Class['::patchwork::manage'] ],
    notify  => Service['uwsgi'],
  }

  service { 'uwsgi':
    ensure => 'running',
    enable => true,
  }
}
