class accounts::params {
  case $::network_eth0 {
    /^10.1.[0-9]{1,2}.0$/ : {
      $environment = "prod"
    }
    /^10.2.[0-9]{1,2}.0$/ : {
      $environment = "prod"
    }
    /^10.17.[0-9]{1,2}.0$/ : {
      $environment = "prod"
    }
	/^10.19.[0-9]{1,2}.0$/ : {
      $environment = "prod"
    }
	/^10.21.[0-9]{1,2}.0$/ : {
      $environment = "prod"
    }
    default: {
      fail("No configuration in module ${module_name} for network ${::network_eth0}")
    }
  }
}
