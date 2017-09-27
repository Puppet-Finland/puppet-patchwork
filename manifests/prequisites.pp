# == Class: patchwork::prequisites
#
# This class install prequisites of patchwork
#
class patchwork::prequisites inherits patchwork::params
{
    include ::git
    include ::python::devel
    include ::python::virtualenv
    include ::python::pip
}
