class base::common {

     include accounts::virtual
     
     Accounts::Virtualgroups <| |>
     Accounts::Virtualuser <| |>

     include ntp
     include customfact
     include sudo
     include base::prod_access
     class {'motd':
        enable  => true,
     }
     include puppet_client
      
     Accounts::Virtualgroups <| |>
     Accounts::Virtualuser <| |>


     class { 'resolver':
          dns_servers => [ '192.168.81.1', '192.168.81.145' ],
          search      => [ 'audsci.local', 'dc01.revsci.net' ],
        }
}

