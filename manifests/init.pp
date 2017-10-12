# == Class: patchwork
#
# This class sets up patchwork
#
# Currently functionality is limited to installing or removing the package.
#
# == Parameters
#
# [*manage*]
#   Whether to manage patchwork using Puppet. Valid values are true (default) 
#   and false.
# [*manage_monit*]
#   Manage (nginx) monit with Puppet. Valid values are true (default) and false.
# [*manage_packetfilter*]
#   Manage packet filtering rules with Puppet. Valid values are true (default) 
#   and false.
# [*secret_key*]
#   Secret key for patchwork. Should be a randomly generated string.
# [*allowed_hosts*]
#   An array or string of host(s) allowed to connect to Patchwork. Defaults to '*'.
# [*default_from_email*]
#   Email address visible in emails patchwork sends. No default value.
# [*admins*]
#   Admins of this patchwork instance as a hash in format { 'name' => 'email' }
# [*enable_rest_api*]
#   Enable the REST API. Valid values are true and false (default). If set to 
#   true, then REST API access is allowed from IP/subnet defined by 
#   $admin_allow_address_ipv4 parameter, below. 
# [*db_password*]
#   Password for the Postgresql database which patchwork uses.
# [*imap_server*]
# [*imap_port*]
# [*imap_username*]
# [*imap_password*]
#   Settings for getmail
# [*mailboxes*]
#   Mailboxes to fetch using getmail. A string or an array of strings. Default 
#   to 'ALL'.
# [*server_name*]
#   Nginx server_name. Used for default http -> https redirect.
# [*sslcert_basename*]
# [*sslcert_bundlefile*]
#   See ::sslcert::set for details
# [*allow_address_ipv4*]
#   Allow connections through the firewall from this IPv4 address/subnet. 
#   Defaults to 'anyv4' (allow any address).
# [*allow_address_ipv6*]
#   Allow connections through the firewall from this IPv6 address/subnet. 
#   Defaults to 'anyv6' (allow any address).
# [*admin_allow_address_ipv4*]
#  Allow connections to the administration frontend at /admin from this 
#  address/subnet. Defaults to '127.0.0.1'. Blocking happens at application 
#  (nginx) level.
#
# == Authors
#
# Samuli Seppänen <samuli@openvpn.net>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class patchwork
(
    Boolean $manage = true,
    Boolean $manage_monit = true,
    Boolean $manage_packetfilter = true,
            $secret_key,
            $allowed_hosts = '*',
            $default_from_email,
            $admins,
            $enable_rest_api = false,
            $db_password,
            $imap_server,
            $imap_port,
            $imap_username,
            $imap_password,
            $server_name,
            $sslcert_basename,
            $sslcert_bundlefile,
            $mailboxes = 'ALL',
            $allow_address_ipv4 = 'anyv4',
            $allow_address_ipv6 = 'anyv6',
            $admin_allow_address_ipv4 = '127.0.0.1'

) inherits patchwork::params
{

if $manage {

    include ::patchwork::prequisites
    include ::patchwork::install

    class { '::patchwork::config':
        secret_key               => $secret_key,
        allowed_hosts            => $allowed_hosts,
        default_from_email       => $default_from_email,
        admins                   => $admins,
        enable_rest_api          => $enable_rest_api,
        db_password              => $db_password,
        server_name              => $server_name,
        imap_server              => $imap_server,
        imap_port                => $imap_port,
        imap_username            => $imap_username,
        imap_password            => $imap_password,
        mailboxes                => $mailboxes,
        sslcert_basename         => $sslcert_basename,
        sslcert_bundlefile       => $sslcert_bundlefile,
        admin_allow_address_ipv4 => $admin_allow_address_ipv4,
    }

    class { '::patchwork::service':
        imap_username => $imap_username,
    }

    if $manage_monit {
        include ::patchwork::monit
    }

    if $manage_packetfilter {
        class { '::webserver::packetfilter':
            allow_address_ipv4 => $allow_address_ipv4,
            allow_address_ipv6 => $allow_address_ipv6,
        }
    }
}
}
