class accounts::params {
  case $::network_eth0 {
    /^192.168.2.0$/ : {
      $environment = "prod"
    }
    default: {
      fail("No configuration in module ${module_name} for network ${::network_eth0}")
    }
  }
}
