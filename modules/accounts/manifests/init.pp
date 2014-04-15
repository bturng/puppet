# Used to define/realize users on Puppet-managed systems
#
class accounts inherits accounts::params {

  @accounts::virtualgroups { 'admins':
    gid             => 1001,
  }
  @accounts::virtualgroups { 'users':
    gid             => 1005,
  }

  @accounts::virtualuser { 'bturng':
    uid             =>  6030,
    ensure          =>  present,
    realname        =>  'Bryce Turng',
    groups          =>  ['admins'],
    pass            =>  '!!',
  }

  #This is the only functional account that is created by puppet.
  @accounts::virtualuser { 'ansible':
    uid             =>  53,
    realname        => 'Ansible',
    pass            => '!!',
  }
  @accounts::virtualuser { 'root':
    uid             =>  0,
    realname        => 'root',
    system          => true,
    groups          => ['bin','daemon','sys','adm','disk','wheel'],
    shell           => '/bin/bash',
    pass            => '$1$LjrKL324$Kd3kS6xWcM89eA70urd1H/',
  }
}
