# patchwork

A Puppet module for installing and configuring [Patchwork](http://jk.ozlabs.org/projects/patchwork/).
By default this module configures all components (patchwork, getmail, nginx, postgresql, uwsgi) required for Patchwork, but each of those can be managed outside of the module
as well.

# Prerequisites

If you use this module to configure all aspects of Patchwork you need all the
modules defined in [Puppetfile](Puppetfile).

# Module usage

Example usage from [vagrant/patchwork.pp](vagrant/patchwork.pp):

    $admins                   = { 'admin' => 'admin@vagrant.example.lan' }
    $allowed_hosts            = '*'
    $default_from_email       = 'patchwork@vagrant.example.lan'
    $db_password              = 'vagrant'
    $imap_password            = 'vagrant'
    $imap_port                = 993
    $imap_server              = 'localhost'
    $imap_username            = 'vagrant'
    $mailboxes                = 'Inbox'
    $revision                 = 'v3.0.5'
    $secret_key               = 'Kp|:Ych*AF^WIg4*<lpb}6T.P4etTI2E)qs.g4uqaSE0V*TPWs'
    $server_name              = 'patchwork.vagrant.example.lan'
    $admin_allow_address_ipv4 = '192.168.59.0/24'
    $rest_allow_address_ipv4  = '192.168.59.0/24'
    $ssl                      = true
    $ssl_cert                 = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
    $ssl_key                  = '/etc/ssl/private/ssl-cert-snakeoil.key'
    
    class { '::patchwork':
      manage_datasource        => true,
      manage_nginx             => true,
      revision                 => $revision,
      secret_key               => $secret_key,
      allowed_hosts            => $allowed_hosts,
      enable_rest_api          => true,
      default_from_email       => $default_from_email,
      db_password              => $db_password,
      admins                   => $admins,
      server_name              => $server_name,
      imap_server              => $imap_server,
      imap_port                => $imap_port,
      imap_username            => $imap_username,
      imap_password            => $imap_password,
      mailboxes                => $mailboxes,
      admin_allow_address_ipv4 => $admin_allow_address_ipv4,
      rest_allow_address_ipv4  => $rest_allow_address_ipv4,
      ssl                      => $ssl,
      ssl_cert                 => $ssl_cert,
      ssl_key                  => $ssl_key,
    }

For details see [manifests/init.pp](manifests/init.pp).
