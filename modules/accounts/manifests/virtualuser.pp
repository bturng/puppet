# Defined type for creating virtual user accounts
#
define accounts::virtualuser (
  $uid,
  $realname,
  $pass,
  $ensure=present,
  $groups=undef,
  $home=undef,
  $home_mode=undef,
  $system=false,
  $shell="/bin/bash") {

  if $groups {    
    $mygroups = $groups
  } else {
    $mygroups = []
  }

  if $home {    
    $myhome = $home
  } else {
    $myhome = "/home/${title}"
  }
  if $home_mode {    
    $myhome_mode = $home_mode
  } else {
    $myhome_mode = "0750"
  }


  case $ensure {
    present: {
      Group[$title] -> User[$title]
    }
    absent: {
      User[$title] -> Group[$title]
    }
  }

  user { $title:
    ensure            =>  $ensure,
    uid               =>  $uid,
    gid               =>  $title,
    shell             =>  $shell,
    home              =>  $myhome,
    comment           =>  $realname,
    password          =>  $pass,
    groups            =>  $mygroups,
    managehome        =>  true,
    membership        =>  inclusive,
    system            =>  $system,
  }

  group { $title:
    gid               =>  $uid,
    ensure            =>  $ensure,
  }

  if $ensure == present {
    file { "$myhome":
      ensure            =>  directory,
      owner             =>  $title,
      group             =>  $title,
      mode              =>  "$myhome_mode",
      require           =>  [ User[$title], Group[$title] ],
    }
   
    if $system == false {
   
      file { "${myhome}/.ssh":
        ensure            =>  directory,
        owner             =>  $title,
        group             =>  $title,
        mode              =>  '0700',
        require           =>  [ File["${myhome}"] ],
      }
      file { "${myhome}/.ssh/authorized_keys":
        ensure            => present,
        owner             => $title,
        group             => $title,
        mode              => '400',
        source            => [ "puppet:///modules/accounts/${title}_${accounts::params::environment}.pub",
                               "puppet:///modules/accounts/${title}.pub",
                               "puppet:///modules/accounts/empty.pub" ];					   
      }
    }
  }
}
