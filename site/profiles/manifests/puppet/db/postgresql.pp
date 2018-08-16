# Instala e mantem um PostgreSQL para o PuppetDB
#
# @summary Instala e mantem um PostgreSQL para o PuppetDB
#
# @example
#   include profiles::puppet::db::postgresql

class profiles::puppet::db::postgresql (
  $listen_addresses = $::trusted['certname'],
) {

  if 'linux' == $facts['kernel'] {
    class { 'puppetdb::database::postgresql':
      listen_addresses => $listen_addresses,
    }
  }

}
