node default {
     include base::common
}
node "utility.audsci.local" {
     include base::common
     

     include bind
       bind::server::conf { '/etc/named.conf':
         listen_on_addr    => [ '127.0.0.1', '192.168.81.145' ],
         listen_on_v6_addr => [ 'any' ],
         allow_transfer    => [ '10.1.30.207', '10.1.10.24'],
         allow_query       => [ 'localhost', '192.168.81.0/24' ],
         zones             => {
           'audsci.local' => [
           'type master',
           'file "forward.audsci"',
           ],
           '81.168.192.in-addr.arpa' => [
           'type master',
           'file "reverse.audsci"',
           ],
         },
       }

       bind::server::file { [ 'forward.audsci', 'reverse.audsci' ]:
         source_base => 'puppet:///modules/bind/',
       }
}

node "cobbler.audsci.local" {
     include base::common
     class { 'apache': }
     class { 'cobbler':
              manage_dhcp => 1,
              purge_distro   => false,
              purge_repo     => false,
              purge_profile  => false,
              purge_system   => false,
     }


}
