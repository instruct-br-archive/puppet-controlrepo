# Manage kernel limits in the host
#
# @param entries hash of limits that should be managed.
# Default to an empty hash.
#
# @param purge_config_not_managed flag to indicate if not managed
# limits should be keept. Default to false.
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::limits (
  Hash    $entries                  = {},
  Boolean $purge_config_not_managed = false,
) {

  class { 'limits':
    purge_limits_d_dir => $purge_config_not_managed,
    entries            => $entries,
  }

}
