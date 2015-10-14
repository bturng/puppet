# == Class: osrepos
#


define osrepos::yum ($reponame      = undef,
                     $ensure    = present,
                     $filename  = undef,
                     $baseurl   = undef,
                     $gpgcheck  = '0',
                     $gpgkey    = undef,
                     $enable    = '1',
                     $priority  = '10',
                     $source    = undef,
                     $content   = undef) {
  
  if $filename == undef {
    fail ("osrepos::yum requires that the filename attribute be specified.")
  }
    
  if $ensure == 'present' {
    # if source or content is given, then use that file. 
    if $source or $content {
      file {"/etc/yum.repos.d/${filename}":
        ensure  => present,
        owner   => 'root',
        group   => 'root', 
        mode    => '0444',
        backup  => false,
        source  => $source,
        content => $content,
        notify  => Exec['osrepos:yum cache refresh'],
      } -> Package <||>
    } else {
      # We need to build a yum repo file from the info given
      file {"/etc/yum.repos.d/${filename}":
        ensure  => present,
        owner   => 'root',
        group   => 'root', 
        mode    => '0444',
        backup  => false,
        content => template("${module_name}/yum.repo.erb"),
        notify  => Exec['osrepos:yum cache refresh'],
      } -> Package <||>
    }      
  } else {
    # Remove the existing file if it is present
    file {"/etc/yum.repos.d/${filename}":
      ensure  => absent,
      notify  => Exec['osrepos:yum cache refresh'],
    } -> Package <||>
  }                  
}


define osrepos::install_key ($ensure    = 'present',
                             $source    = undef,
                             $content   = undef) {
                               
  case $::operatingsystem {
    'CentOS': { $keydir = '/etc/pki/rpm-gpg' }
    default: { fail ("${module_name} module does not support ${operatingsystem} for installing keys.") }
  }
                               
  if $ensure == 'present' {
    if $source == undef and $content == undef {
      fail("Either source or content must be declared for osrepos::install_key")
    }
  
    file {"${keydir}/${title}":
      ensure  => present,
      owner   => 'root',
      group   => 'root', 
      mode    => '0444',
      source  => $source,
      content => $content,
      backup  => false,
    } -> Package <||>
  } else {
    file {"${keydir}/${title}":
      ensure => absent,
    }
  }
  
}


class osrepos {
  
  File {
    ensure  => present,
    owner  => 'root',
    group  => 'root', 
    mode   => '0444',
    backup  => false, 
  }
  
  if $::operatingsystem == 'CentOS' {
    # Install the OS GPG keys
    case $::operatingsystemmajrelease {
      '5': {
        osrepos::install_key {'RPM-GPG-KEY-CentOS-5':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-CentOS-5",
        }
      }
      
      '6': {
        osrepos::install_key {'RPM-GPG-KEY-CentOS-6':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-CentOS-6",
        }
        osrepos::install_key {'RPM-GPG-KEY-CentOS-Debug-6':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-CentOS-Debug-6",
        }
        osrepos::install_key {'RPM-GPG-KEY-CentOS-Security-6':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-CentOS-Security-6",
        }
        osrepos::install_key {'RPM-GPG-KEY-CentOS-Testing-6':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-CentOS-Testing-6",
        }
      }
  
      '7': {
        osrepos::install_key {'RPM-GPG-KEY-CentOS-7':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-CentOS-7",
        }
        osrepos::install_key {'RPM-GPG-KEY-CentOS-Debug-7':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-CentOS-Debug-7",
        }
        osrepos::install_key {'RPM-GPG-KEY-CentOS-Testing-7':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-CentOS-Testing-7",
        }
      }
    } 
  }
  
  
  if $::osfamily == 'RedHat' {
    # Install the EPEL GPG keys
    case $::operatingsystemmajrelease {
      '5': {
        osrepos::install_key {'RPM-GPG-KEY-EPEL-5':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-EPEL-5",
        }
      }
      
      '6': {
        osrepos::install_key {'RPM-GPG-KEY-EPEL-6':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-EPEL-6",
        }
      }
      
      '7': {
        osrepos::install_key {'RPM-GPG-KEY-EPEL-7':
          source => "puppet:///modules/${module_name}/yum/RPM-GPG-KEY-EPEL-7",
        }
      }
    }
    
    
    # Setup to refresh the yum cache when repos changed
    exec {'osrepos:yum cache refresh':
      command     => '/usr/bin/yum clean all',
      user        => 'root', 
      refreshonly => true,
    }
  }




  # Setup the gemrc file
  $gemRepoURL = 'http://dc1-repo01.dc01.revsci.net/repos/external/gem/'
  file {'osrepos::gemrc':
    name   => '/etc/gemrc', 
    content => template("${module_name}/gemrc.erb"),
  } -> Package <||>
  
  # some systems have gem looking in /usr/local/etc/gemrc
  file {'/usr/local/etc/gemrc':
    ensure  => link,
    target  => '/etc/gemrc',
    require => File['osrepos::gemrc'],
  } -> Package <||>

}
