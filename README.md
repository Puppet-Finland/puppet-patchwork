# patchwork

A Puppet module for installing and configuring patchwork. Includes monit and 
firewall support.

# Module usage

Install patchwork and all its dependencies including commercial SSL 
certificates:

    class { '::patchwork':
        secret_key               => 'secret',
        allowed_hosts            => '*',
        admin_allow_address_ipv4 => '10.0.0.0/8',
        rest_allow_address_ipv4  => 'all',
        enable_rest_api          => true,
        default_from_email       => 'patchwork@example.org',
        db_password              => 'secret',
        admins                   => { 'john' => 'john@example.org' },
        server_name              => 'patchwork.example.org',
        imap_server              => 'imap.example.org',
        imap_port                => 993,
        imap_username            => 'patchwork@example.org',
        imap_password            => 'secret',
        mailboxes                => 'Inbox',
        sslcert_basename         => 'example.org',
        sslcert_bundlefile       => 'DigiCertCA.crt,
    }

For detail see [init.pp](manifests/init.pp).

# TODO

* Automatically load postgresql grants
* Make the module less Ubuntu-specific
* Allow defining the installation directory (hardcoded to /opt/patchwork)
