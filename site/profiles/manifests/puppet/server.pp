# Installs and configure the Puppet Server in the host
#
# @summary installs the Puppet Server service
#
# @param version the package version. Default to '5.3.4-1.el7'
#
# @param enable_puppetca flag to enable the CA feature.
# The first host probably will enable it, but Puppet compilers will
# disable it. Default to true
#
# @param autosign flag to enable agents certificates auto signing.
# Default to true
#
# @param java_args string with the parameters to JVM.
#
# @param puppetdb_host string with the PuppetDB Server hostname.
# Default to the certname in the Puppet certificate, probably localhost
#
# @param puppetca_host string with the Puppet CA hostname.
# Default to the certname in the Puppet certificate, probably localhost
#
# @param main_server string with the Puppet Server hostname.
# Default to the certname in the Puppet certificate, probably localhost
#
# @example
#   include profiles::puppet::server
#
# [Remember: No empty lines between comments and class definition]
class profiles::puppet::server (
  String  $version         = '5.3.4-1.el7',
  String  $puppetdb_host   = $trusted['certname'],
  String  $puppetca_host   = $trusted['certname'],
  String  $main_server     = $trusted['certname'],
  Boolean $enable_puppetca = true,
  Boolean $autosign        = true,
  String  $java_args       = '-Xms1g -Xmx2g -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger',
) {

  if 'linux' == $facts['kernel'] {

    include profiles::linux::jvm

    class { 'puppetserver':
      version     => $version,
      java_args   => $java_args,
      enable_ca   => $enable_puppetca,
      ca_server   => $puppetca_host,
      main_server => $main_server,
      autosign    => $autosign,
      require     => [
        Class['profiles::linux::jvm'],
      ],
    }

    class { 'puppetdb::master::config':
      puppetdb_server             => $puppetdb_host,
      puppetdb_soft_write_failure => true,
      manage_storeconfigs         => true,
      manage_report_processor     => true,
      enable_reports              => true,
    }

    include profiles::linux::firewall

    firewalld::custom_service{ 'puppet':
      short       => 'puppet',
      description => 'Puppet Agent access to Puppet Server',
      port        => [
        {
          'port'     => '8140',
          'protocol' => 'tcp',
        },
        {
          'port'     => '8140',
          'protocol' => 'udp',
        },
      ],
    }

    firewalld_service { 'Allow Puppet in Public zone':
      ensure  => present,
      service => 'puppet',
      zone    => 'public',
    }

    augeas { 'disable_puppet_warning_deprecation':
      context => '/files/etc/puppetlabs/puppet/puppet.conf',
      changes => 'set main/disable_warnings deprecations',
    }
  }

}
