# Manage OS packages in the host
#
# @param package_list the list of packages that should be installed in the host.
# Default to an empty list.
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::packages (
  Array $package_list = [],
) {

  include epel

  package { $package_list:
    ensure  => present,
    require => [
      Class['epel'],
    ]
  }

}
