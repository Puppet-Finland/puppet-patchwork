#
# @summary configure nginx for Patchwork
#
class patchwork::nginx
(
  Stdlib::Fqdn                   $server_name,
  Stdlib::Absolutepath           $www_root,
  Stdlib::Absolutepath           $static_root,
  String                         $uwsgi,
  Stdlib::IP::Address::V4        $admin_allow_address_ipv4,
  Stdlib::IP::Address::V4        $rest_allow_address_ipv4,
  Boolean                        $ssl,
  Optional[Stdlib::Absolutepath] $ssl_cert,
  Optional[Stdlib::Absolutepath] $ssl_key,

) inherits patchwork::params
{

  if $ssl {
    unless ($ssl_cert and $ssl_key) {
      fail("ERROR: must define \$ssl_cert and \$ssl_key when \$ssl = true")
    }

    $listen_port = 443
  } else {
    $listen_port = 80
  }

  file {
    default:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    ;
    [$www_root]:
    ;
    [$static_root]:
      require => File[$www_root],
    ;
  }

  class { '::nginx':
    nginx_version => $::patchwork::params::nginx_version,
  }

  ::nginx::resource::server { $server_name:
    ensure              => 'present',
    listen_port         => $listen_port,
    ssl                 => $ssl,
    ssl_cert            => $ssl_cert,
    ssl_key             => $ssl_key,
    listen_options      => 'default_server',
    ipv6_enable         => true,
    ipv6_listen_options => 'default_server',
    autoindex           => 'off',
    gzip_types          => 'text/css application/javascript',
    www_root            => $www_root,
    uwsgi               => $uwsgi,
    location_cfg_append => { 'allow' => 'all' },
  }

  ::nginx::resource::location {
    default:
      ensure   => 'present',
      server   => $server_name,
      uwsgi    => $uwsgi,
      ssl      => true,
      ssl_only => true,
    ;
    ['admin']:
      location            => '/admin',
      location_cfg_append => {'allow' => $admin_allow_address_ipv4,
                              'deny'  => 'all', },
    ;
    ['api']:
      location            => '/api',
      location_cfg_append => {'allow' => $rest_allow_address_ipv4,
                              'deny'  => 'all' },
    ;
    ['static']:
      location            => '/static',
      location_alias      => '/var/www/patchwork',
      location_cfg_append => { 'allow'   => 'all', 'expires' => '3h', },
      uwsgi               => undef,
    ;
  }
}
