

class base::prod_access {

  sudo::conf { 'base_admins':
    priority => 01,
    content  => "#This is managed by Puppet\n\n%admins ALL=(ALL) NOPASSWD: ALL\n",
  }

  sudo::conf { 'ansible':
    priority => 03,
    content  => "#Managed by Puppet\n\nansible ALL=(ALL) NOPASSWD: ALL\n",
  }

}
