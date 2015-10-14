# == Class: customfact
#
# Full description of class customfacts here.
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
#  class { customfacts:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#

define customfact::file ($source=undef,
                        $content=undef,
                        $mode='0555') {
    file {"/etc/facts.d/${title}":
        ensure  => present,
        source  => $source,
        content => $content,
        mode    => $mode,
        require => File['/etc/facts.d'],
    }
}

class customfact {
    File {
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        backup  => false,
    }

    #
    # Setup for custom facts
    #
    # Add the facts-doc-d.rb into the Ruby load path

    if $::rubyversion < '1.9.0' {
      # Older copies of ruby have a rubygems package that needs to be loaded
      package {'rubygems':
        ensure  => present,
      }
    }
    exec {$::rubysitedir:
      command  => "mkdir -p $::rubysitedir",
      path     => ['/bin', '/usr/bin'],
      creates  => $::rubysitedir,
    }
    file {'site ruby facter directory':
        ensure  => directory,
        name    => "${::rubysitedir}/facter",
        require => Exec[$::rubysitedir],
    }
    file {'facts-dot-d.rb':
        ensure  => present,
        name    => "${::rubysitedir}/facter/facts-dot-d.rb",
        source  => "puppet:///modules/${module_name}/facts-dot-d.rb",
    }
    file {'/etc/facts.d':
        ensure  => directory,
        require => File['facts-dot-d.rb'],
    }

    # clean up any failed attempts to install custom facts
    exec {'/bin/rm /etc/facts.d/*puppettmp*':
        returns   => [0,1,2],
        require   => File['/etc/facts.d'],
        onlyif    => '/bin/ls /etc/facts.d/*puppettmp*',
        before    => File['/etc/facts.d/customfact-diskspace.rb'],
    }

    # remove first generation custom facts
    exec {'/bin/rm /etc/facts.d/custom-fact-*':
        returns   => [0,1,2],
        onlyif    => '/bin/ls /etc/facts.d/custom-fact-*',
        require   => File['/etc/facts.d'],
    }
    file {'/etc/facts.d/standard.yaml':
        ensure  => absent,
    }
    file {'/usr/local/bin/custom-fact-generator.rb':
        ensure  => absent,
    }

    #
    # Add custom facts to the system.
    #
    customfact::file {'customfact-diskspace.rb':
        source => "puppet:///modules/${module_name}/customfact-diskspace.rb",
        mode   => '0555',
    }
    customfact::file {'customfact-pythonsitedir.py':
        source => "puppet:///modules/${module_name}/customfact-pythonsitedir.py",
        mode   => '0555',
    }
    customfact::file {'customfact-java.rb':
        source => "puppet:///modules/${module_name}/customfact-java.rb",
        mode   => '0555',
    }
    customfact::file {'customfact-linkspeed.rb':
        source => "puppet:///modules/${module_name}/customfact-linkspeed.rb",
        mode   => '0555',
    }
    #customfact::file {'customfact-raid-status.pl':
    #    source => "puppet:///modules/${module_name}/customfact-raid-status.pl",
    #    mode   => '0555',
    #}
    #customfact::file {'customfact-sudoers.sh':
    #    source => "puppet:///modules/${module_name}/customfact-sudoers.sh",
    #    mode   => '0555',
    #}
    #customfact::file {'customfact-resolvconf.sh':
    #    source => "puppet:///modules/${module_name}/customfact-resolvconf.sh",
    #    mode   => '0555',
    #}
    #customfact::file {'customfact-opensslversion.sh':
    #    source => "puppet:///modules/${module_name}/customfact-opensslversion.sh",
    #    mode   => '0555',
    #}
    #customfact::file {'customfact-mcollective.rb':
    #    source => "puppet:///modules/${module_name}/customfact-mcollective.rb",
    #    mode   => 0555,
    #}
    customfact::file {'customfact-gateway.sh':
       source => "puppet:///modules/${module_name}/customfact-gateway.sh",
       mode   => 0555,
    }

}
