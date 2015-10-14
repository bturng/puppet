
File {
    owner => 'root',
    group => 'root',
    mode  => '0444',
}


file {'motd-system-stats':
    name => '/etc/motd.d/01-system-stats',
    ensure => 'present',
    content => template('/etc/puppet/templates/system-stats.erb'),
    notify => Exec['motd::generate motd']
}


#
#  Generate the motd file from the components in /etc/motd.d
#
exec {'motd::generate motd':
    command => '/usr/local/bin/motd generate',
}
