# Manages the SELinux in the host
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::selinux {

  class { 'selinux':
    mode => 'enforcing',
    type => 'targeted',
  }

  selinux::boolean { 'puppetagent_manage_all_files':
    ensure     => on,
    persistent => true,
  }

}
