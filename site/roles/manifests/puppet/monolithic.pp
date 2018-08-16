# Configure a monolithic Puppet Server to start a new Puppet infrastructure.
#
# This role installs and configures:
# - Puppet Server CA
# - Puppet DB
# - ActiveMQ
# - MCollective client and server
# - Puppet Board
# - PostgreSQL
# - r10k gem
#
# [Remember: No empty lines between comments and class definition]
class roles::puppet::monolithic {

  include profiles::base::linux
  class { 'profiles::puppet::agent':
    server => $trusted['certname'],
  }
  include profiles::puppet::db::aio
  include profiles::puppet::r10k
  include profiles::puppet::server
  include profiles::puppet::activemq
  include profiles::puppet::mco::client
  include profiles::puppet::board


  Class['profiles::base::linux']
  -> Class['profiles::puppet::agent']
  -> Class['profiles::puppet::db::aio']
  -> Class['profiles::puppet::r10k']
  -> Class['profiles::puppet::server']
  -> Class['profiles::puppet::activemq']
  -> Class['profiles::puppet::mco::client']
  -> Class['profiles::puppet::board']

}
