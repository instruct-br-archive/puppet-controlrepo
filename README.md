# Instruct Puppet Default ControlRepo

This is a standard Puppet controlrepo to start a new Puppet infrastructure. It will help you to configure and start your Pupppet services in no time.

## Before starting

This controlrepo was designed to be applied in the Puppe Server CA host, because it is the first piece to be configured. For this host you will need a CentOS 7 with `root` access, at least 2 processors, 6 GB of RAM, and 30 GB of disk.

We strongly recommend to keep all Puppet infrastructure hosts as CentOS 7, but Ubuntu and Debian can be used as well, but they are not so well tested!!

## Setting up your own ControlRepo

The first step is to read this README to the end.

The second step should be to install the Puppet 5 repository:

    $ yum install http://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm

Then install the pre-reqs packages:

    $ yum install git gem puppet-agent

Then it will be necessary to install some gems:

    $ gem install r10k --no-document

After that, you should create your configuration files, as detailed below.

### r10k

    $ mkdir --parent --verbose /etc/r10k

#### /etc/r10k/r10k.yaml

``` yaml
---
cachedir: '/var/cache/r10k'
#proxy: 'https://proxy.example.com:8888'
sources:
  puppet:
    remote : 'https://github.com/instruct-br/puppet-controlrepo.git'
    basedir: '/etc/puppetlabs/code/environments'
    prefix : true
```

    $ /usr/local/bin/r10k --config /etc/r10k/r10k.yaml deploy environment --verbose

### Manifests files

All the configuration files, by default, should be in the directory `/etc/controlrepo`. The full directory tree can be created with this command:

    $ mkdir --parent --verbose /etc/controlrepo/{data,manifests}

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

===== /etc/puppetlabs/puppet/puppet.conf =====
...
[main]
hiera_config = /etc/controlrepo/hiera.yaml
...
===== ===== =====

REVER DAQUI PARA BAIXO
###############################################################

## Repositório de controle do Puppet

Este é o novo repositório de controle do Puppet.

Esse repositório foi construído para suportar a Stack 5 do Puppet.

### Pré-requisitos

Para fazer o desenvolvimento local é necessário ter instalado os seguintes componentes em seu notebook/desktop:

- VirtualBox 5.2.x
- Vagrant 2.x
- Puppet Agent 5.x + R10k

Após instalar o agente, instale o r10k.

    /opt/puppetlabs/puppet/bin/gem install r10k

* Em seu host é necessário ter um chave ssh com permissões para baixar os projetos no GitLab.

### Estrutura básica

Dentro deste projetos temos vários arquivos e pastas, mas os principais são:

- `data/`: contém os dados do Hiera;
- `environment.yaml`: arquivo básico de configuração do ambiente Puppet;
- `hiera.yaml`: arquivo que configura o Hiera 5;
- `manifests/`: contém os arquivos `.pp` que farão o relacionamento dos _hosts_ atendidos com os papéis disponíveis;
- `modules/`: contém módulos Puppet externos ao projeto;
- `Puppetfile`: arquivo que configura os módulos externos disponíveis, via `r10k`;
- `site/profiles/`: contém os perfis (_profiles_) Puppet do projeto;
- `site/roles/`: contém os papéis (_roles_) Puppet do projeto;

## Desenvolvendo código

### Usando o Puppet Toolkit

O primeiro passo é clonar o repositório do Puppet Toolkit e do controlrepo para seu ambiente local:

    git clone https://github.com/instruct-br/puppet-toolkit
    cd puppet-toolkit
    git clone https://git.rnp.br/gsc-puppet-video-labs/rnp-controlrepo-v2 control-repo
    cd control-repo

O segundo passo é baixar os módulos externos:

    /opt/puppetlabs/puppet/bin/r10k puppetfile install -v debug

Para iniciar uma VM local com o Puppet Server monolítico (Puppet Server CA, PostgreSQL, PuppetDB, ActiveMQ), faça o seguinte:

    cd ..
    vagrant up puppet

Esta VM estará vazia, apenas com o sistema operacional básico. Para inicializar o ambiente monolítico execute:

    vagrant ssh puppet
    sudo -i
    yum install git vim epel-release -y
    puppet cert generate puppet.dev
    cd /etc/puppetlabs/code/environments
    rm -rf production/
    ln -s /vagrant/control-repo production
    puppet apply -e "include roles::puppet::monolitico"

O provisionamento leva cerca de 6 minutos e irá instalar e configurar os seguintes componentes:

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

- Instala e configura um servidor Puppet Monolitico
  - Padroniza o OS Linux
  - Mantém o agente puppet
  - Mantém o serviço mcollective
  - Mantém o cliente mcollective (orquestrador)
  - Instala e mantém o serviço ActiveMQ
  - Instala e mantém o serviço PuppetDB
  - Instala e mantém o serviço PostgreSQL para o PuppetDB
  - Instala e mantém o serviço Puppet Board
  - Instala e mantém o serviço Puppet Server
  - Instala e mantém configurações do r10k

#### roles::puppet::compiler

- Instala e configura um servidor Puppet Compiler
  - Padroniza o OS Linux
  - Mantém o agente puppet
  - Mantém o serviço mcollective
  - Instala e mantém o serviço Puppet Server
  - Instala e mantém configurações do r10k

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

```
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

Ativa o serviço firewalld e libera a porta 22 para acesso ssh.

#### profiles::linux::jvm

Instala JVM no sistema operacional.

#### profiles::linux::limits

Configura security/limits no sistema operacional.

#### profiles::linux::packages

Instala pacotes básicos no sistema operacional.

Exemplo de hash:

```
profile::linux::packages::package_list:
  - vim-enhanced
  - screen
  - nano
  - rsync
  - telnet
  - curl
  - tcpdump
  - tree
  - lynx
```

#### profiles::linux::selinux

- Ativa o SELinux no sistema operacional, modo enforcing.

#### profiles::linux::sshd

- Configura e mantém o serviço sshd no sistema operacional.
- Proibe ssh via root
- Define porta TCP 22 como padrão para o ssh.

#### profiles::linux::sudo

- Carrega classe de gerenciamento do sudo no sistema operacional

#### profiles::linux::users

- Cria usuários comuns no sistema operacional.

Exemplo de hash:

```
rofile::linux::users:users_hash:
  'oscar':
    comment: 'Oscar Ximiti'
    groups:
      - 'devs'
    sshkeys:
      - 'hash da chave'
  'aurora':
    comment: 'Aurora da Silva'
    groups:
      - 'devs'
    sshkeys:
      - 'hash da chave'
```

#### profiles::linux::vagrant

- Classe utilizada apenas para desenvolvimento local do controlrepo.
- Quando detectar o virtualbox como hypervisor, coloca o usuário vagrant como admin

#### profiles::puppet::activemq

- Instala e configura o ActiveMQ para uso do Mcollective

#### profiles::puppet::agent

- Configura o Puppet Agent do node

#### profiles::puppet::board

- Instala e configura do Puppet Board

#### profiles::puppet::r10k

- Instala e configura o R10k

#### profiles::puppet::server

- Instala e configura o serviço Puppet Server

#### profiles::puppet::mco::client

- Configura o serviço Mcollective Server e Client.

#### profiles::puppet::mco::server

- Configura o serviço Mcollective Server.

#### profiles::puppet::db::aio

- Instala e configura o PuppetDB + PostgreSQL

#### profiles::puppet::db::server

- Instala e configura o PuppetDB Server.

#### profiles::puppet::db::postgresql

- Instala e configura o PostgreSQL para o PuppetDB.
