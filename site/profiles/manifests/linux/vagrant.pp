# Configure the vagrant user in local boxes
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::vagrant {

  require profiles::linux::sudo

  user { 'vagrant':
    ensure => present,
  }

  sudo::conf { 'vagrant':
    ensure         => present,
    content        => '%vagrant ALL=(ALL) NOPASSWD: ALL',
    sudo_file_name => 'vagrant',
  }

}
