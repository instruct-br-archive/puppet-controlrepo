#
# Configuracao de um Puppet Server Compiler
#
# Componentes:
# - Puppet Server
# - Mcollective Server
# - R10k
#
# Antes de instalar o compiler é preciso configurar
# o certificado do node com o mesmo DNS_ALT_NAME
# do servidor master ca
#

class roles::puppet::compiler {

  include profiles::base::linux
  include profiles::puppet::r10k
  include profiles::puppet::mco::server
  include profiles::puppet::server

  Class['profiles::base::linux']
  -> Class['profiles::puppet::r10k']
  -> Class['profiles::puppet::mco::server']
  -> Class['profiles::puppet::server']

}
