# Instala e configura o MCO Server
#
# @summary Instala e configura o MCO Server
#
# @example
#   include profiles::puppet::mco::server

class profiles::puppet::mco::server (
  String        $mco_user = 'mcollective',
  String        $mco_pass = 'p4ssw0rd',
  String        $mco_port = '61614',
  Array[String] $mco_host = [
    $trusted['certname'],
  ],
) {

  class { '::mcollective':
    use_client           => false,
    use_server           => true,
    broker_type          => 'activemq',
    broker_pool_hosts    => $mco_host,
    broker_pool_port     => $mco_port,
    broker_pool_user     => $mco_user,
    broker_pool_password => $mco_pass,
    mco_loglevel         => 'debug',
  }

}
