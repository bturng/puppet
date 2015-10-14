class base::resolv {

      class { 'resolver':
          dns_servers => [ '10.1.10.23' , '10.1.30.207', '10.1.30.208' ],
          search      => [ 'uscorp.audsci.com' , 'dc01.revsci.net', 'sea1.audsci.net', 'audsci.net' ],
        }
}
