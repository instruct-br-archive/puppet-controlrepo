# Manage the time synchronization in the host
#
# @param ntp_servers list of time synchronization servers. Default to ['pool.ntp.org']
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::timesync (
  Array[String] $ntp_servers = [
    'pool.ntp.org',
  ],
) {

  class { '::chrony':
    pool_use       => false,
    servers        => $ntp_servers,
    service_ensure => 'running',
    service_enable => true,
  }

}
