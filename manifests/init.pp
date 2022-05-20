# @summary set up Patchwork
#
# @param manage
#   Whether to manage patchwork using Puppet.
# @param manage_datasource
#   Whether to manage the postgresql server and database
# @param manage_getmail
#   Whether to manage getmail
# @param manage_nginx
#   Whether to manage nginx
# @param manage_uwsgi
#   Whether to manage uwsgi
# @param static_root
#   Location of Patchwork's static files.
# @param secret_key
#   Secret key for patchwork. Should be a randomly generated string.
# @param allowed_hosts
#   An array or string of host(s) allowed to connect to Patchwork.
# @param default_from_email
#   Email address visible in emails patchwork sends.
# @param admins
#   Admins of this patchwork instance as a hash in format { 'name' => 'email' }
# @param enable_rest_api
#   Enable the REST API.
# @param db_password
#   Password for the Postgresql database which patchwork uses.
# @param imap_server
#   Email host
# @param imap_port
#   Email port
# @param imap_username
#   Email username
# @param imap_password
#   Email password
# @param mailboxes
#   Mailboxes to fetch using getmail.
# @param server_name
#   Nginx server_name. Used for default http -> https redirect.
# @param revision
#   Version of Patchwork to install. Should match a Git tag or other Git reference.
#   Example: v3.0.5.
# @param www_root
#   Root of the webserver
# @param static_root
#   Directory for Patchwork's static files. Assumed to be directly under www_root.
# @param uwsgi
#   Patch to Patchwork's uwsgi socket
# @param admin_allow_address_ipv4
#   IP address / subnet to allow admin connections from
# @param rest_allow_address_ipv4
#   IP address / subnet to allow REST connections from
# @param in_rspec
#   A parameter used to work around a function lookup issue
#   in rspec-puppet. Let this be at the default value.
#
class patchwork
(
  String                                                $secret_key,
  String                                                $default_from_email,
  Hash[String,String]                                   $admins,
  String                                                $db_password,
  Stdlib::Fqdn                                          $imap_server,
  Integer                                               $imap_port,
  String                                                $imap_username,
  String                                                $imap_password,
  String                                                $server_name,
  String                                                $revision,
  Boolean                                               $manage = true,
  Boolean                                               $manage_datasource = true,
  Boolean                                               $manage_getmail = true,
  Boolean                                               $manage_nginx = true,
  Boolean                                               $manage_uwsgi = true,
  Variant[Enum['*'], Stdlib::Fqdn, Array[Stdlib::Fqdn]] $allowed_hosts = '*',
  Boolean                                               $enable_rest_api = false,
  Variant[String,Array[String]]                         $mailboxes = 'ALL',
  Stdlib::Absolutepath                                  $www_root = '/var/www',
  Stdlib::Absolutepath                                  $static_root = '/var/www/patchwork',
  String                                                $uwsgi = 'unix:/run/uwsgi/app/patchwork/socket',
  Stdlib::IP::Address::V4                               $admin_allow_address_ipv4 = '127.0.0.1',
  Stdlib::IP::Address::V4                               $rest_allow_address_ipv4 = '127.0.0.1',
  Boolean                                               $in_rspec = false,

) inherits patchwork::params
{

  if $manage {

    include ::patchwork::prerequisites

    class { '::patchwork::install':
      revision => $revision,
    }

    class { '::patchwork::config':
      secret_key         => $secret_key,
      allowed_hosts      => $allowed_hosts,
      default_from_email => $default_from_email,
      admins             => $admins,
      enable_rest_api    => $enable_rest_api,
      db_password        => $db_password,
      server_name        => $server_name,
      static_root        => $static_root,
    }

    if $manage_datasource {
      class { '::patchwork::postgresql':
        db_password => $db_password,
        in_rspec    => $in_rspec,
        before      => Class['::patchwork::manage'],
      }
    }

    # Run Patchwork's manage.py commands
    include ::patchwork::manage

    # Receive mail locally using getmail
    if $manage_getmail {
      class { '::patchwork::getmail':
        imap_server   => $imap_server,
        imap_port     => $imap_port,
        imap_username => $imap_username,
        imap_password => $imap_password,
        mailboxes     => $mailboxes,
      }
    }

    # Configure uwsgi
    if $manage_uwsgi {
      include ::patchwork::uwsgi
    }

    # Configure nginx
    if $manage_nginx {
      class { '::patchwork::nginx':
        server_name              => $server_name,
        www_root                 => $www_root,
        static_root              => $static_root,
        uwsgi                    => $uwsgi,
        admin_allow_address_ipv4 => $admin_allow_address_ipv4,
        rest_allow_address_ipv4  => $rest_allow_address_ipv4,
        before                   => Class['::patchwork::manage'],
      }
    }
  }
}
