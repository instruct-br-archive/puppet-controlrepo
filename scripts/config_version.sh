#!/bin/bash
if [ -e "$1"/"$2"/.r10k-deploy.json ]
then
  /opt/puppetlabs/puppet/bin/ruby "$1"/"$2"/scripts/code_manager_config_version.rb "$1" "$2"
elif [ -e /opt/puppetlabs/server/pe_version ]
then
  /opt/puppetlabs/puppet/bin/ruby "$1"/"$2"/scripts/config_version.rb "$1" "$2"
else
  # shellcheck disable=SC2015

  # Option 1: full hash commit ID
  # hash /usr/bin/git && /usr/bin/git --git-dir "$1"/"$2"/.git rev-parse HEAD 2> /dev/null || date +%s

  # Option 2: hash commit, commit author name, commit date, commit first line
  hash /usr/bin/git && /usr/bin/git --git-dir "$1"/"$2"/.git log --pretty=format:"%h - %an, %ad : %s" -1 2> /dev/null ||
  date -Is
fi
