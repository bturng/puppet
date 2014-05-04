class base {

  notify {"Connected to ${servername}":
    loglevel => notice,
  }

  include accounts

  Accounts::Virtualgroups <| |>
  Accounts::Virtualuser <| |>
  resources {
    'user':
      purge                => false;
  }

  include '::ntp'

  include nrpe

  include yum

  class { 'resolver': 
  dns_servers => [ '192.168.2.22' , '192.168.2.1' ],
  search      => 'myowntechpros.com',
  }


  if $hostname =~ /nagios.*$/ {
        include nagios
        include network
        network::if::static { 'eth0':
           ensure    => 'up',
           ipaddress => '192.168.2.31',
           netmask   => '255.255.255.0',
           gateway      => '192.168.2.1',
           macaddress   => '00:0C:29:57:8D:15',
}


  }
  
  if $hostname =~ /dns.*$/ {
        include bind
        bind::server::conf { '/etc/named.conf':
        listen_on_addr    => [ 'any' ],
        listen_on_v6_addr => [ 'any' ],
        forwarders        => [ '192.168.2.1', '75.75.75.75' ],
        allow_query       => [ 'localnets' ],
                zones             => {
                        'myowntechpros.com' => [
                        'type master',
                        'file "myowntechpros.com.zone"',
                        ],
                        '2.168.192.in-addr.arpa' => [
                        'type master',
                        'file "2.168.192.in-addr.arpa"',
                        ],
                },
        }
        bind::server::file { [ 'myowntechpros.com.zone', '2.168.192.in-addr.arpa' ]:
          source_base => 'puppet:///modules/bind/',
        }
  }
}
