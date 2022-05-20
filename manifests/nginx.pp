#
# @summary configure nginx for Patchwork
#
class patchwork::nginx
(
  Stdlib::Fqdn            $server_name,
  Stdlib::Absolutepath    $www_root,
  Stdlib::Absolutepath    $static_root,
  String                  $uwsgi,
  Stdlib::IP::Address::V4 $admin_allow_address_ipv4,
  Stdlib::IP::Address::V4 $rest_allow_address_ipv4,

) inherits patchwork::params
{
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

  include ::nginx

  ::nginx::resource::server { $server_name:
    ensure              => 'present',
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
      ensure => 'present',
      server => $server_name,
      uwsgi  => $uwsgi,
    ;
    ['admin']:
      location            => '/admin',
      location_cfg_append => { 'allow' => $admin_allow_address_ipv4 },
    ;
    ['api']:
      location            => '/api',
      location_cfg_append => { 'allow' => $rest_allow_address_ipv4 },
    ;
    ['static']:
      location            => '/static',
      location_alias      => '/var/www/patchwork',
      location_cfg_append => { 'allow'   => 'all', 'expires' => '3h', },
      uwsgi               => undef,
    ;
  }
}
