# Instala e configura um Puppet DB
#
# @summary Instala e configura um Puppet DB
#
# @example
#   include profiles::puppet::db::server

class profiles::puppet::db::server (
  String  $db_version       = '5.2.4-1.el7',
  Integer $no_ssl_port      = 8080,
  Integer $ssl_port         = 8081,
  String  $listen_address   = '0.0.0.0',
  String  $postgres_host    = $trusted['certname'],
  String  $ssl_key_path     = "/etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem",
  String  $ssl_cert_path    = "/etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem",
  String  $ssl_ca_cert_path = '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
  Hash    $java_args        = {
    '-Xms' => '256m',
    '-Xmx' => '512m',
  },
) {

  if 'linux' == $facts['kernel'] {

    include profiles::linux::jvm

    class { 'puppetdb::server':
      database_host           => $postgres_host,
      listen_address          => $listen_address,
      listen_port             => $no_ssl_port,
      disable_ssl             => false,
      ssl_listen_port         => $ssl_port,
      ssl_key                 => file($ssl_key_path),
      ssl_cert                => file($ssl_cert_path),
      ssl_ca_cert             => file($ssl_ca_cert_path),
      ssl_deploy_certs        => true,
      ssl_set_cert_paths      => true,
      manage_firewall         => false,
      java_args               => $java_args,
      disable_update_checking => true,
      require                 => [
        Class['profiles::linux::jvm'],
      ],
    }

    include profiles::linux::firewall

    firewalld::custom_service{'puppetdb':
      short       => 'puppetdb',
      description => 'Puppet Server access to PuppetDB',
      port        => [
        {
          'port'     => $no_ssl_port,
          'protocol' => 'tcp',
        },
        {
          'port'     => $no_ssl_port,
          'protocol' => 'udp',
        },
        {
          'port'     => $ssl_port,
          'protocol' => 'tcp',
        },
        {
          'port'     => $ssl_port,
          'protocol' => 'udp',
        },
      ],
    }

    firewalld_service { 'Allow PuppetDB in Public zone':
      ensure  => present,
      service => 'puppetdb',
      zone    => 'public',
    }
  }

}
