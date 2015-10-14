# == Class: cron
#
# Puppet class to manage installing crontab files and restarting cron.
#
# === Parameters
#
# cron::file takes only one parameter which is the Puppet source location
# for the file to setup as a crontab. 
#
# === Examples
#
#  include cron
#
#  cron::file {'/etc/cron.d/motd-stats': 
#      source  => "puppet:///modules/${module_name}/motd-stats.cron",
#  }
#
#  file {'/etc/cron.d/someservice':
#      # Settings for manually setting crontab file
#      ensure   => absent,
#      notify   => Service['cron'],
#  }
#
# === Authors
#
# Gerard Hickey <ghickey@ebay.com>
#


define cron::file ($source=undef, $content=undef) {
    if $::operatingsystem == 'Solaris' {
        # Solaris puppet agent does not always write to root's crontab 
        # Here we have do a bit more gyrations to be able to get a 
        # crontab entry created.      
        
        if $source != undef {
            fail("Solaris machines are not able to accept the source parameter when creating crontab entries: ${source}")
        }
        
        $header = "#####\n# ${title} created by Puppet\n"
        $cron_entry = crond_to_crontab("${header}${content}")
        
        exec {$title:
            creates  => "${settings::confdir}/flags/cronfile-${title}",
            command  => "crontab -l | perl -ne 'END{ print \"${cron_entry}\\n\"} print' | crontab; if [ `crontab -l | grep -c \"# ${title} created by Puppet\"` -gt 0 ]; then touch ${settings::confdir}/flags/cronfile-${title}; else exit 1; fi",
            path     => ['/bin', '/usr/bin', '/usr/local/bin', '/opt/bin'],
            user     => 'root',
            require  => File['puppet::flags directory'],
            unless   => "crontab -l | egrep '# ${title}'",
        }
    } elsif $::operatingsystem == 'RedHat' or $::operatingsystem == 'CentOS' or $::operatingsystem == 'Ubuntu' or $::operatingsystem == 'Debian' {
        # Create an entry in /etc/cron.d for Linux machines
        file {"/etc/cron.d/${title}":
            ensure   => present,
            owner    => 'root',
            mode     => '0444',
            source   => $source, 
            content  => $content,
            notify   => Service['cron'],
        }
    } else {
        fail "cron::file does not support ${::operatingsystem}"
    }
}


class cron {
    
    File {
        ensure   => present, 
        owner    => 'root',
        group    => 'root', 
        mode     => '0444',
        backup   => false,
    }
    
    
    
    
    
    
    
    # Signal the cron daemon after installing a new crontab entry 
    service {'cron':
        ensure   => running, 
        enable   => true, 
        name     => $::operatingsystem ? {
                        'Ubuntu'  => 'cron',
                        'RedHat'  => 'crond',
                        'CentOS'  => 'crond',
                        'Solaris' => 'cron',
                        'Debian'  => 'cron',
                        default   => 'crond',
                    },
    }

}
