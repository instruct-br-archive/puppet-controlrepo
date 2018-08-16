# Installs a Puppet Board in the host
#
# @summary installs the Puppet Board
#
# @param port the port the service should listen to.
# Default to 8888
#
# @param version the version should be installed.
# Default to 'v0.3.0'
#
# @example
#   include profiles::puppet::board
#
# [Remember: No empty lines between comments and class definition]
class profiles::puppet::board (
  Integer $port    = 8888,
  String  $version = 'v0.3.0'
) {

  require epel

  include apache

  selinux::port { 'allow-http-puppetboard':
    ensure   => 'present',
    seltype  => 'http_port_t',
    protocol => 'tcp',
    port     => $port,
  }

  class { 'apache::mod::wsgi':
    wsgi_socket_prefix => '/var/run/wsgi',
  }

  class { 'puppetboard':
    manage_git        => true,
    manage_virtualenv => true,
    revision          => $version,
  }

  class { 'puppetboard::apache::vhost':
    vhost_name => 'puppet.dev',
    port       => $port,
  }

  firewalld_port { 'Puppet Board Port':
    ensure   => present,
    zone     => 'public',
    port     => $port,
    protocol => 'tcp',
  }

}
