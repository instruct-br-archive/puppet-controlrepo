# Manage timezone configuration in the host
#
# @param region the region of the world where the host is. Default to 'America'
#
# @param locality the timezone locality where the host is. Default to 'Sao_Paulo'
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::timezone (
  String $region   = 'America',
  String $locality = 'Sao_Paulo',
) {

  class { '::timezone':
    region   => $region,
    locality => $locality,
  }

}
