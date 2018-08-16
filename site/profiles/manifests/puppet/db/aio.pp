# Class profiles::puppet::db::aio

class profiles::puppet::db::aio {

  class { 'puppetdb::database::postgresql':
      listen_addresses => $trusted['certname'],
      before           => Class['puppetdb::server'],
  }

  include profiles::puppet::db::server

}
