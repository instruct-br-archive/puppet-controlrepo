# Ensure the basic Linux configuration in the host
#
# @summary ensure the Linux baseline is applied to the host
#
# @example
#   include profiles::base::linux
#
# [Remember: No empty lines between comments and class definition]
class profiles::base::linux {
  include profiles::linux::admins
  include profiles::linux::firewall
  include profiles::linux::limits
  include profiles::linux::packages
  include profiles::linux::selinux
  include profiles::linux::sshd
  include profiles::linux::sudo
  include profiles::linux::timesync
  include profiles::linux::users

  if 'virtualbox' == $::facts['virtual'] {
    include profiles::linux::vagrant
  }

}
