class puppet_client {
  
  $site_label = asci_site_label()
  case $site_label {
    'DC1': {
      $puppetmaster = "puppet.audsci.local"
      $masters = ['puppet', 'puppet.audsci.local']

    }
    default: {
      fail("No configuration in module ${module_name} for site ${site_label}")
    }
  }
  
  # set the puppetca values
  $puppetca = "puppet.audsci.local"
  if $::fqdn == 'puppet.audsci.local' {
      $serve_ca = 'true'
  } else {
      $serve_ca = 'false'
  }
  
  # enable foreman
  $foremanServer = 'dc1-foreman01.dc01.revsci.net'
  
  File{
      ensure  => present,
      owner  => 'root',
      group  => 'root',
      mode    => '0444',
      backup  => false,
  }
  
  file {'/etc/puppet/puppet.conf':
    content => template("${module_name}/puppet.conf.erb"),
  }

  file{"/usr/local/sbin/puppet-agent-run.sh":
      mode   => '0500',
      source => "puppet:///modules/${module_name}/puppet-agent-run.sh",
  }
  
  cron::file {'puppet-agent':
    content => template("${module_name}/puppet-cron.erb"),
  }
  
  cron { 'purge_clientbucket' :
    command   => '/bin/find /var/lib/puppet/clientbucket -type f -mtime +7 -exec rm {} \;',
    user      => 'root',
    hour      => '1',
    minute    => '15',
    ensure    => absent,
  }

  cron { 'run_puppetclient' :
    command   => '/usr/bin/puppet agent --test >/dev/null 2>&1',
    user      => 'root',
    hour      => '*',
    minute    => fqdn_rand(30),
    ensure    => absent,
  }

  #
  # Create the standard managed by puppet banner
  #
  motd::file {'managed-by-puppet':
      level   => '10',
      content => template("${module_name}/managed-by-puppet.erb"),
  }
  
}
