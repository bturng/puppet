# Used to define/realize users on Puppet-managed systems
#
class accounts::virtual {

  @accounts::virtualgroups { 'admins':
    gid             => 1001,
  }
  @accounts::virtualgroups { 'devs':
    gid             => 1004,
  }
  @accounts::virtualgroups { 'users':
    gid             => 1005,
  }

  @accounts::virtualuser { 'brycet':
    uid             =>  6030,
    ensure          =>  present,
    realname        =>  'Bryce Turng',
    groups          =>  ['admins'],
  }

  @accounts::virtualuser { 'ansible':
    uid             =>  53,
    realname        => 'Ansible',
    pass            => '*',
  }
}
