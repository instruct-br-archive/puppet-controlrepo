# Instruct Puppet Default ControlRepo

This is a standard Puppet controlrepo to start a new Puppet infrastructure. It will help you to configure and start your Pupppet services in no time.

## Before starting

This controlrepo was designed to be applied in the Puppet Server CA host, because it is the first piece to be configured. For this host you will need a CentOS 7 with `root` access, at least 2 processors, 6 GB of RAM, and 30 GB of disk.

We strongly recommend to keep all Puppet infrastructure hosts as CentOS 7, but Ubuntu and Debian can be used as well, but they are not so well tested!!

## Setting up your own ControlRepo

The first step is to read this README to the end.

The second step should be to install the Puppet agent. We suggest using [this project](https://github.com/instruct-br/puppet-installer) to automate it, but this simple command will do this for now:

    # curl https://raw.githubusercontent.com/instruct-br/puppet-installer/master/installer.sh | bash -s

Then install the pre-reqs packages:

    # yum install --assumeyes git gem

Then it will be necessary to install some gems:

    # gem install r10k --no-document

After that, you should create your configuration files, as detailed below.

### r10k

    # mkdir --parent --verbose /etc/puppetlabs/r10k

#### /etc/puppetlabs/r10k/r10k.yaml

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

This is the main Hiera data file, and it will hold all configuration shared by all client hosts. The first important parameter is the remote URL to the client controlrepo where their own profiles and roles will be keept.

``` yaml
---
profiles::puppet::r10k::remote: 'git@gitserver:group/project.git'
```

### Config version script

#### /etc/controlrepo/bin/config_script.sh

This script will generate an usefull Puppet version to the received catalog:

``` shell
#!/bin/bash
hash git && git --git-dir /etc/puppetlabs/code/environments/$1/.git log --pretty=format:"%h - %an, %ad : %s" -1
```

## Sync the remote controlrepo

Now we already can use r10k to synchronize the environment and download Puppet Forge modules:

    # /opt/puppetlabs/puppet/bin/r10k deploy environment --config /etc/r10k/r10k.yaml --verbose

## Running the Puppet agent

If we are configuring the Puppet Server CA node, we have to create the CA certificate before the first Puppet run. You can do this with this command:

    # /opt/puppetlabs/puppet/bin/puppet cert generate "$(hostname --fqdn)" --dns_alt_names=puppet

Then we need to set the correct environment to our new Puppet infrastructure, with this command:

    # /opt/puppetlabs/puppet/bin/puppet config set environment puppet_master --section main

And then we can set our Hiera config file create before:

    # /opt/puppetlabs/puppet/bin/puppet config set hiera_config /etc/controlrepo/hiera.yaml --section main

With all set up, it is time to run the Puppet agent locally to install all others tools:

    # /opt/puppetlabs/puppet/bin/puppet apply -e 'include roles::puppet::monolithic'

###############################################################

## Repositório de controle do Puppet

Este é the novo repositório de controle do Puppet.

Esse repositório foi construído para suportar a Stack 5 do Puppet.

### Pré-requisitos

Para fazer the desenvolvimento local é necessário ter instalado os seguintes componentes em seu notebook/desktop:

- VirtualBox 5.2.x
- Vagrant 2.x
- Puppet Agent 5.x + R10k

Após instalar the agente, instale the r10k.

    /opt/puppetlabs/puppet/bin/gem install r10k

- Em seu host é necessário ter um chave ssh com permissões para baixar os projetos no GitLab.

### Estrutura básica

Dentro deste projetos temos vários arquivos and pastas, mas os principais são:

- `data/`: contém os dados do Hiera;
- `environment.yaml`: arquivo básico de configuração do ambiente Puppet;
- `hiera.yaml`: arquivo que configure the Hiera 5;
- `manifests/`: contém os arquivos `.pp` que farão the relacionamento dos _hosts_ atendidos com os papéis disponíveis;
- `modules/`: contém módulos Puppet externos ao projeto;
- `Puppetfile`: arquivo que configure os módulos externos disponíveis, via `r10k`;
- `site/profiles/`: contém os perfis (_profiles_) Puppet do projeto;
- `site/roles/`: contém os papéis (_roles_) Puppet do projeto;

## Desenvolvendo código

### Usando the Puppet Toolkit

O primeiro passo é clonar the repositório do Puppet Toolkit and do controlrepo para seu ambiente local:

    git clone https://github.com/instruct-br/puppet-toolkit
    cd puppet-toolkit
    git clone https://git.rnp.br/gsc-puppet-video-labs/rnp-controlrepo-v2 control-repo
    cd control-repo

O segundo passo é baixar os módulos externos:

    /opt/puppetlabs/puppet/bin/r10k puppetfile install -v debug

Para iniciar uma VM local com the Puppet Server monolítico (Puppet Server CA, PostgreSQL, PuppetDB, ActiveMQ), faça the seguinte:

    cd ..
    vagrant up puppet

Esta VM estará vazia, apenas com the sistema operacional básico. Para inicializar the ambiente monolítico execute:

    vagrant ssh puppet
    sudo -i
    yum install git vim epel-release -y
    puppet cert generate puppet.dev
    cd /etc/puppetlabs/code/environments
    rm -rf production/
    ln -s /vagrant/control-repo production
    puppet apply -e "include roles::puppet::monolitico"

O provisionamento leva cerca de 6 minutos and irá instalar and configurar os seguintes componentes:

- Puppet Server 5.3.4
- Puppet Agent 5.5.4
- PuppetDB 5.2.4
- PostgreSQL Server 9.6
- ActiveMQ 5.15.4
- Puppet Board v0.3.0

## Compatibilidade

Este repositório suporta as seguintes versões:

- Puppet OSS 5.5.4 ou mais atual
- Puppet Enterprise 2017.1.0 ou mais atual

## Classes

### Roles

#### roles::puppet::monolitico

- Installs and configures um servidor Puppet Monolitico
  - Padroniza the OS Linux
  - Mantém the agente puppet
  - Mantém the serviço mcollective
  - Mantém the cliente mcollective (orquestrador)
  - Install and mantém the serviço ActiveMQ
  - Install and mantém the serviço PuppetDB
  - Install and mantém the serviço PostgreSQL para the PuppetDB
  - Install and mantém the serviço Puppet Board
  - Install and mantém the serviço Puppet Server
  - Install and mantém configurações do r10k

#### roles::puppet::compiler

- Installs and configures um servidor Puppet Compiler
  - Padroniza the OS Linux
  - Mantém the agente puppet
  - Mantém the serviço mcollective
  - Install and mantém the serviço Puppet Server
  - Install and mantém configurações do r10k

### Profiles

#### profiles::base::linux

Esta classe inclui as seguintes classes para padronização do SO Linux.

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

- Cria usuários para sistema operacional no grupo admin.
- Consede privilégios de root ao grupo admin

Exemplo de hash no hiera:

``` yaml
profile::linux::admins::group: 'admins'
profile::linux::admins::users:
  'gutocarvalho':
    comment: 'Guto Carvalho'
    groups:
      - 'admins'
    sshkeys:
      - 'hash da chave'
  'miguel':
    comment: 'Miguel'
    groups:
      - 'admins'
    sshkeys:
      - 'hash da chave'
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

- Configures sshd service.

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

- Installs and configures MCOllective's ActiveMQ service

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
