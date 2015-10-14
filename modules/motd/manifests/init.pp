# == Class: motd
#
# The motd class installs a script, /usr/local/bin/motd, to allow administrators
# to create messages in the motd file. Please review the README file for an
# explanation of the motd script. In the standard legal disclaimer and a 
# banner stating that the system is under Puppet control are also installed. 
# 
# By default the class will also install a periodic job that will generate
# system statistics in the motd file. The generation of the statistics can 
# be controlled with parameters to the motd class. 
# 
# In addition the motd class defines motd::file for the convience of installing
# motd component files. The motd::file definition takes 2 parameters for 
# creating the component file that are defined in the parameter section.
# 
#
# === Parameters
#
# The following parameters may be specified for the motd class.
#
# [*status*]
#   Enables or disables the statistics generation in the motd file. By 
#   default this parameter is set to 'enable'. Any other value will 
#   disable the statistics generation.
#
# [*schedule*]
#   
#
# [*status_template*]
#
#
# The following parameters are specified for the motd::file definition.
#
# [*level*]
#
#
# [*source*]
#
#
# [*content*]
#
#
#
# === Examples
#
#  class { motd:
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

define motd::file ($level=undef, $source=undef, $content=undef) {
    # There needs to be either source or content
    if $source == undef and $content == undef {
        fail("motd::file requires either a source or a content parameter")
    }

    # A level must be specified
    if $level == undef {
        fail("motd::file requires that a level be specified")
    }
    
    $padded_level = num2padded_string($level, 2)
    
    file {"/etc/motd.d/${padded_level}-${title}":
        ensure   => present,
        owner    => 'root', 
        mode     => '0444',
        source   => $source,
        content  => $content,
        backup   => false,
        require  => File['/etc/motd.d'],
        notify   => Exec['motd::generate motd'],
    }
}



class motd ($enable='enable',
            $schedule='0,5,10,15,20,25,30,35,40,45,50,55',
            $status_template="puppet:///modules/${module_name}/system-stats.erb") {

    include cron
    
    File {
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        backup => false,
    }
    
    file {'/etc/motd':
        ensure => 'present',
        mode   => '0664',
    }

    file {'/etc/motd.d':
        ensure => directory,
    }
    
    # install the motd script
    file {'/usr/local/bin/motd':
        ensure => present,
        mode   => '0555',
        source => "puppet:///modules/${module_name}/motd",
    }
    
    #
    # Create the standard authorized use banner
    #
    motd::file {'authorized-use':
        level  => '00',
        source => "puppet:///modules/${module_name}/authorized-use.txt",
    }
    
    
    # 
    # Setup for the automatic generation of system stats
    #
    if $enable == 'enable' {
        file {'/etc/puppet/manifests/motd-stats.pp':
            ensure   => present,
            source   => "puppet:///modules/${module_name}/motd-stats.pp",
            require  => File['/etc/puppet/manifests'],
        }

        file {'/etc/puppet/templates/system-stats.erb':
            ensure   => present,
            source   => $status_template,
            require  => File['/etc/puppet/templates'],
        }

        # Add a cron job to collect system stats
        cron::file {'motd-stats': 
            content  => template("${module_name}/motd-stats-cron.erb"),
        }
    }
    
    
    
    #
    #  Generate the motd file from the components in /etc/motd.d
    #
    exec {'motd::generate motd':
        command => '/usr/local/bin/motd generate',
        path    => '/usr/local/bin:/usr/bin:/bin',
        onlyif  => '/usr/bin/test `find /etc/motd.d -newer /etc/motd | wc -l` -ne 0',
        require => [File['/etc/motd.d'], File['/usr/local/bin/motd']],
    }
    
    
    
}
