# == Class: zsh
#
# Full description of class zsh here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { zsh:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2011 Your name here, unless otherwise noted.
#
class zsh {

  ###############################################################
  ## Add the parameter(s) needed to ensure that the package is ##
  ## managed before the configuration file is updated.         ##
  ###############################################################

  package { 'zsh':
    ensure => present,
  }
  file { '/etc/zshrc':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/zsh/zshrc',
  }

}
