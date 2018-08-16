# Installs and configures the ActiveMQ service in the host
#
# @summary installs the ActiveMQ package and starts the service
#
# @param version the string version of the ActiveMQ to be installed.
# Default to '5.15.4'
#
# @param jvm_args the string with JVM parameters.
#
# @param mco_config flag to indicate if MCollective requirements should
# be set up. Default to true
#
# @example
#   include profiles::puppet::activemq
#
# [Remember: No empty lines between comments and class definition]
class profiles::puppet::activemq (
  String  $version            = '5.15.4',
  String  $checksum           = '5ff48112978a3d1a40162b55eab72a32',
  String  $checksum_type      = 'md5',
  String  $jvm_args           = '-Xms1g -Xmx1g',
  String  $home               = '/opt/activemq',
  String  $user               = 'activemq',
  String  $group              = 'activemq',
  Boolean $mco_config         = true,
  String  $mco_user           = 'mcollective',
  String  $mco_pass           = 'p4ssw0rd',
  String  $system_config_path = '/etc/sysconfig',
) {

  class  { 'activemq':
    version            => $version,
    checksum           => $checksum,
    checksum_type      => $checksum_type,
    memory             => $jvm_args,
    home               => $home,
    user               => $user,
    group              => $group,
    mco_config         => $mco_config,
    mco_user           => $mco_user,
    mco_pass           => $mco_pass,
    system_config_path => $system_config_path,
  }

  include profiles::linux::firewall

  firewalld_port { 'Open port 61613 in the Public zone':
    ensure   => present,
    zone     => 'public',
    port     => 61613,
    protocol => 'tcp',
  }

  firewalld_port { 'Open port 61614 in the Public zone':
    ensure   => present,
    zone     => 'public',
    port     => 61614,
    protocol => 'tcp',
  }

}
