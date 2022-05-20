#
# @summary install patchwork
#
class patchwork::install
(
  String $revision

) inherits patchwork::params
{

    $install_dir = '/opt/patchwork'

    file { $install_dir:
        ensure => 'directory',
    }

    vcsrepo { $install_dir:
        ensure   => 'present',
        provider => 'git',
        source   => 'https://github.com/getpatchwork/patchwork.git',
        revision => $revision,
        notify   => Class['::patchwork::manage'],
    }
}
