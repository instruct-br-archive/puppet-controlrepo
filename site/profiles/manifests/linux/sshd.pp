# Manage the sshd service in the host
#
# @param port the port the service will listen on. Default to 22.
#
# @param permit_root_login indicates if the 'root' user should login by SSH.
# Default to 'no'.
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::sshd (
  String $port              = '22',
  String $permit_root_login = 'no',
) {

  sshd_config { 'PermitRootLogin':
    ensure => present,
    value  => $permit_root_login,
    notify => [
      Service['sshd'],
    ]
  }

  sshd_config { 'PasswordAuthentication':
    ensure => present,
    value  => 'yes',
    notify => [
      Service['sshd'],
    ]
  }

  sshd_config { 'Port':
    ensure => present,
    value  => $port,
    notify => Service['sshd'],
  }

  firewalld_port { 'Open SSH port in the Public zone':
    ensure   => present,
    zone     => 'public',
    port     => $port,
    protocol => 'tcp',
  }

  firewalld_service { 'Allow SSH in Public zone':
    ensure  => present,
    service => 'ssh',
    zone    => 'public',
  }

  service { 'sshd':
    ensure => running,
    enable => true,
  }

}
