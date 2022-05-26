#
# @summary configure postgresql for Patchwork
#
class patchwork::postgresql
(
  String  $db_password,
  Boolean $in_rspec,

) inherits patchwork::params
{
  class { '::postgresql::server': }

  # This is a nasty workaround to the issue where rspec-puppet
  # is unable to find postgresql::postgresql_password function,
  # possibly due to the namespacing.
  $password = $in_rspec ? {
    true    => $db_password,
    default => postgresql::postgresql_password('patchwork', $db_password),
  }

  ::postgresql::server::db { 'patchwork':
    user     => 'patchwork',
    password => $password,
    grant    => 'ALL',
  }

  ::postgresql::server::grant { 'patchwork':
    role        => 'patchwork',
    db          => 'patchwork',
    privilege   => 'CONNECT',
    object_type => 'database',
    require     => Postgresql::Server::Db['patchwork'],
  }
}
