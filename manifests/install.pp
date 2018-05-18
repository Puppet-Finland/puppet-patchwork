# == Class: patchwork::install
#
# This class installs patchwork
#
class patchwork::install inherits patchwork::params
{

    $install_dir = '/opt/patchwork'

    file { $install_dir:
        ensure => 'directory',
    }

    vcsrepo { $install_dir:
        ensure   => 'present',
        provider => 'git',
        source   => 'git://github.com/getpatchwork/patchwork',
        revision => 'v2.0.0',
        notify   => Exec['patchwork manage.py'],
    }
}
