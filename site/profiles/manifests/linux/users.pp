# Expose local users creation from Hiera.
#
# @param users_hash list of user type to manage them in the system.
# Default to an empty list.
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::users (
  Hash $users_hash = {},
) {

  $users_hash.each |String $user, Hash $data| {
    accounts::user { $user:
      * => $data,
    }
  }

}
