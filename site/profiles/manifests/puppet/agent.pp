# Configure the Puppet Agent
#
# @summary configure the Puppet Agent in the host
#
# @param certname the name the host should present itself to the Server.
# Default to the certname in the Puppet certificate
#
# @param environment the Puppet environment the host should be configured with.
# Default to 'production'
#
# @param server the Puppet server the host should request the catalog to.
# Default to 'puppet'
#
# @param interval the interval, in seconds, the agent should wait between runs.
# Default to 3600 seconds (one hour)
#
# @example
#   include profiles::puppet::agent
#
# [Remember: No empty lines between comments and class definition]
class profiles::puppet::agent (
  String  $certname    = $trusted['certname'],
  String  $version     = '5.5.4-1.el7',
  String  $environment = 'production',
  String  $server      = 'puppet',
  Integer $interval    = 3600,
) {

  class { 'puppetagent':
    agent_certname    => $certname,
    agent_version     => $version,
    agent_environment => $environment,
    agent_runinterval => $interval,
    agent_server      => $server,
  }

}
