# Used to define/realize users on Puppet-managed systems
#
class base::accounts {

     include accounts::virtual

     realize (accounts::virtualgroups['admins'])
     realize (accounts::virtualgroups['devs'])
     realize (accounts::virtualgroups['users'])

     realize (accounts::virtualuser['brycet'])
     realize (accounts::virtualuser['ansible'])

}
