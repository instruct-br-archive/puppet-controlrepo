# Creates and manage local admin users in the host
#
# @param groups the list of local groups that will be admins in the host.
# Default to an empty list
#
# @param users the list of local users that will be admins in the host.
# Default to an empty list
#
# @example
#   include profiles::linux::admins
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::admins (
  Optional[String] $groups = undef,
  Optional[Hash]   $users  = undef,
) {

  require profiles::linux::sudo

  Accounts::User {
    purge_sshkeys => true,
  }

  if $groups {
    group { $groups:
      ensure => 'present'
    }

    sudo::conf { $groups:
      priority => 10,
      content  => "%${groups} ALL=(ALL) NOPASSWD: ALL",
    }
  }

  if $users {
    $users.each |String $user, Hash $data| {
      accounts::user { $user:
        * => $data,
      }
    }
  }

}
