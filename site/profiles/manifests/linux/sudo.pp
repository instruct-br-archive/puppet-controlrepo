# Configure sudo features
#
# @param purge_config_not_managed flag to remove sudo configuration not
# managed by Puppet. If your serve is already configured, disable it. Default to true.
#
# @example
#   include profiles::linux::sudo
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::sudo (
  Boolean $purge_config_not_managed = true,
) {

  class{ 'sudo':
    purge => $purge_config_not_managed,
  }

  sudo::conf { 'admins-sudo':
    priority => 50,
    content  => "%sudo	ALL=(ALL)	ALL",
  }

  sudo::conf { 'admins-wheel':
    priority => 51,
    content  => "%wheel	ALL=(ALL)	ALL",
  }

}
