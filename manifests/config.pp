#
# @summary configure Patchwork
#
class patchwork::config
(
  String                                                $secret_key,
  String                                                $default_from_email,
  Hash[String,String]                                   $admins,
  String                                                $db_password,
  String                                                $server_name,
  Variant[Enum['*'], Stdlib::Fqdn, Array[Stdlib::Fqdn]] $allowed_hosts,
  Boolean                                               $enable_rest_api,
  Stdlib::Absolutepath                                  $static_root,

) inherits patchwork::params
{

  # Convert Boolean into correct type of string
  $l_enable_rest_api = $enable_rest_api ? {
    true  => 'True',
    false => 'False',
  }

  # This is required to allow both String and Array parameters as the 
  # validate_* functions are deprecated
  $l_allowed_hosts = flatten(any2array($allowed_hosts))

  # Patchwork configuration file
  file { 'production.py':
    ensure  => 'present',
    owner   => 'root',
    group   => 'www-data',
    mode    => '0640',
    path    => '/opt/patchwork/patchwork/settings/production.py',
    content => template('patchwork/production.py.erb'),
  }

  # Both www-data and getmail users need to read the config file
  if $::patchwork::manage_getmail {
    posix_acl { '/opt/patchwork/patchwork/settings/production.py':
      action     => set,
      permission => ['user:getmail:r--'],
      provider   => posixacl,
      recursive  => false,
      require    => [ User['getmail'], File['/opt/patchwork/patchwork/settings/production.py'] ],
    }
  }
}
