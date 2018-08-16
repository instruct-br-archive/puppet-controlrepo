# Installs and manage the firewall service in the host
#
# @summary installs and manage the firewalld service
#
# @example
#   include profiles::linux::firewall
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::firewall {

  class { 'firewalld':
    default_zone => 'public',
  }

  firewalld_zone { 'public':
    ensure           => present,
    target           => '%%REJECT%%',
    purge_rich_rules => true,
    purge_services   => true,
    purge_ports      => true,
  }

}
