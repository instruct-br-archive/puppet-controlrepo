# Instruct Puppet Default ControlRepo

This is a standard Puppet controlrepo to start a new Puppet 5 infrastructure. It will help you to configure and start your Pupppet services in no time.

## Before starting

This controlrepo was designed to be applied in the Puppet Server CA host, because it is the first piece to be configured. For this host it is recommended:

- a CentOS 7 OS with `root` access
- at least 2 processors
- 6 GB of RAM
- 30 GB of disk
- Internet access

We strongly recommend to keep all Puppet infrastructure hosts as CentOS 7, but Ubuntu and Debian can be used as well, but they are not so well tested!!

## Setting up your own ControlRepo

The first step is to read this README to the end.

The second step should be to install the Puppet agent. We suggest using [this project](https://github.com/instruct-br/puppet-installer) to automate it, but this simple command will install the latest version, for now:

    # curl https://raw.githubusercontent.com/instruct-br/puppet-installer/master/installer.sh | bash -s

Then install the pre-reqs packages:

    # yum install --assumeyes git

Then it will be necessary to install some gems:

    # /opt/puppetlabs/puppet/bin/gem install r10k --no-document

After that, you should create your configuration files, as detailed below.

### r10k

The `r10k` gem is the tool that manages the Puppet environments in the Puppet Server (CA or not). It turns each `git` branch into a Puppet environment. A new directory should be created to keep its config file:

    # mkdir --parent --verbose /etc/puppetlabs/r10k

#### /etc/puppetlabs/r10k/r10k.yaml

This is `r10k` configuration file. Controlrepo URLs are configured in the `sources` section.

``` yaml
---
cachedir: '/opt/puppetlabs/puppet/cache/r10k'
#proxy: 'https://proxy.example.com:8888'
sources:
  puppet:
    remote : 'https://github.com/instruct-br/puppet-controlrepo.git'
    basedir: '/etc/puppetlabs/code/environments'
    prefix : true
```

### Manifests files

All the configuration files, by default, should be in the directory `/etc/controlrepo`. The full directory tree can be created with this command:

    # mkdir --parent --verbose /etc/controlrepo/{data,manifests}

#### /etc/controlrepo/manifests/00_default.pp

This file will setup default configurations to the new environment.

``` puppet
## Default Configurations ##

# To ensure YUM repos will be configured before
# any package installation attempt
Yumrepo <| |> -> Package <| |>

# Disable filebucket backup
File { backup => false }
```

#### /etc/controlrepo/manifests/10_puppet.pp

This file must declare the roles that will be applied to the hosts in the new Puppet infrastructure. This snippet will configure a monolithic server with all the services included, but you should put your hostname in the `node` line:

``` puppet
node 'puppet-all-in-one.company.com' {
  include roles::puppet::monolithic
}
```

### Hiera files

#### /etc/controlrepo/hiera.yaml

This is the Hiera config file. You can copy it as-is to your environment, but feel free to create your own hierarchy.

``` yaml
---
version: 5
defaults:
  datadir: /etc/controlrepo/data
  data_hash: yaml_data
hierarchy:
  - name: "Per-node client data (yaml version)"
    path: "nodes/%{::trusted.certname}.yaml"

  - name: "OSes client data"
    paths:
     - "oses/distro/%{facts.os.name}/%{facts.os.release.major}.yaml"
     - "oses/family/%{facts.os.family}.yaml"

  - name: "Common client data"
    path: "common.yaml"
```

#### /etc/controlrepo/data/common.yaml

This is the main Hiera data file, and it will hold all configuration shared by all client hosts. The first important parameter is the remote URL to the client controlrepo where their own profiles and roles will be kept.

``` yaml
---
profiles::puppet::r10k::remote: 'git@gitserver:group/project.git'
```

### Config version script

#### /etc/controlrepo/bin/config_script.sh

This script will generate an useful Puppet version to the received catalog:

``` shell
#!/bin/bash
hash git && git --git-dir /etc/puppetlabs/code/environments/$1/.git log --pretty=format:"%h - %an, %ad : %s" -1
```

## Sync the remote controlrepo

Now we are ready to use `r10k` to synchronize the environment and download Puppet Forge modules:

    # /opt/puppetlabs/puppet/bin/r10k deploy environment --config /etc/puppetlabs/r10k/r10k.yaml --verbose

## Running the Puppet agent

If we are configuring the Puppet Server CA node, we have to create the CA certificate before the first Puppet run. You can do this with this command:

    # /opt/puppetlabs/puppet/bin/puppet cert generate "$(hostname --fqdn)" --dns_alt_names=puppet,puppetca

Then we need to set the correct environment to our new Puppet infrastructure, with this command:

    # /opt/puppetlabs/puppet/bin/puppet config set environment puppet_master --section main

And then we can set our Hiera config file create before:

    # /opt/puppetlabs/puppet/bin/puppet config set hiera_config /etc/controlrepo/hiera.yaml --section main

With all set up, it is time to run the Puppet agent locally to install all others tools:

    # /opt/puppetlabs/puppet/bin/puppet apply -e 'include roles::puppet::monolithic'

At the end your new Puppet 5 Server will be ready to compile catalogs for the other nodes you point to it.

### Development requirements

To be able to develop new features, to fix bugs or to propose changes in the code, it is necessary to install this tools:

- VirtualBox 5.2.x
- Vagrant 2.x
- Puppet Agent 5.x
- r10k gem

If you still do not have `r10k` installed, after Puppet agent installation process, run this command to install the r10k gem:

    # /opt/puppetlabs/puppet/bin/gem install r10k

### Basic structure

Inside this standard controlrepo we have this files and directories:

- `environment.yaml`: Puppet environment config file;
- `hiera.yaml`: Hiera config file;
- `modules/`: external Puppet modules directory; populated by `r10k`;
- `Puppetfile`: `r10k` config file for the environment;
- `site/profiles/`: Puppet profiles are here;
- `site/roles/`: Puppet roles are here.

## Compatibility

This controlrepo supports this versions:

- Puppet OSS 5.5.4 or higher
- Puppet Enterprise 2017.1.0 or higher

## Available Puppet classes

### Roles

#### roles::puppet::monolithic

- Installs and configures a monolithic Puppet Server
  - Standard OS Linux configurations
  - Configures the puppet-agent
  - Configures the mcollective server
  - Configures the mcollective client
  - Installs and configures the ActiveMQ service
  - Installs and configures the PuppetDB service
  - Installs and configures the PuppetDB PostgreSQL's database
  - Installs and configures the Puppet Board service
  - Installs and configures the Puppet Server service
  - Installs and configures r10k gem

#### roles::puppet::compiler

- Installs and configures a Puppet Compiler Server
  - Standard OS Linux configurations
  - Configures the puppet-agent
  - Configures the mcollective server
  - Installs and configures the Puppet Server service
  - Installs and configures r10k gem

### Profiles

#### profiles::base::linux

This profile contains the following profiles that are included automatically:

- profiles::linux::admins
- profiles::linux::firewall
- profiles::linux::jvm
- profiles::linux::limits
- profiles::linux::packages
- profiles::linux::selinux
- profiles::linux::sshd
- profiles::linux::sudo
- profiles::linux::timesync
- profiles::linux::timezone
- profiles::linux::users

#### profiles::linux::admins

- Create local users on the system.
- Adds the additional group to sudoers configuration so users can become `root`

Hiera example:

``` yaml
profile::linux::admins::group: 'admins'
profile::linux::admins::users:
  'gutocarvalho':
    comment: 'Guto Carvalho'
    groups:
      - 'admins'
    sshkeys:
      - 'public key hash'
  'miguel':
    comment: 'Miguel'
    groups:
      - 'admins'
    sshkeys:
      - 'public key hash'
```

#### profiles::linux::firewall

- Enable firewalld service on the system.

#### profiles::linux::jvm

- Installs and configures a Java Virtual Machine.

#### profiles::linux::limits

- Configures security limits on the system.

#### profiles::linux::packages

- Install basic packages on the system.

Hiera example:

``` yaml
profile::linux::packages::package_list:
  - curl
  - lynx
  - nano
  - rsync
  - screen
  - tcpdump
  - telnet
  - tree
  - vim-enhanced
```

#### profiles::linux::selinux

- Manages SELinux, default on enforcing mode.

#### profiles::linux::sshd

- Configures the sshd service.

#### profiles::linux::sudo

- Manages sudo on the system.

#### profiles::linux::users

- Create local users on the system.

Hiera example:

``` yaml
profile::linux::users:users_hash:
  'oscar':
    comment: 'Oscar Ximiti'
    groups:
      - 'devs'
    sshkeys:
      - 'public key hash'
  'aurora':
    comment: 'Aurora da Silva'
    groups:
      - 'devs'
    sshkeys:
      - 'public key hash'
```

#### profiles::linux::vagrant

- Used only for project local development. When running on a Vagrant box, sets 'vagrant' user as admin.

#### profiles::puppet::activemq

- Installs and configures MCollective's ActiveMQ service

#### profiles::puppet::agent

- Configures Puppet Agent service

#### profiles::puppet::board

- Installs and configures Puppet Board

#### profiles::puppet::r10k

- Installs and configures R10k

#### profiles::puppet::server

- Installs and configures Puppet Server service.

#### profiles::puppet::mco::client

- Installs and configures MCollective Server and Client services.

#### profiles::puppet::mco::server

- Installs and configures MCollective Server service.

#### profiles::puppet::db::aio

- Installs and configures PuppetDB + PostgreSQL.

#### profiles::puppet::db::server

- Installs and configures PuppetDB Server.

#### profiles::puppet::db::postgresql

- Installs and configures PuppetDB's PostgreSQL.
