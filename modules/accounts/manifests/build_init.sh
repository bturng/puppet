#!/bin/bash

OUTFILE="init.pp"
USERFILE="useraccounts.txt"
GROUPFILE="groups.txt"

cat << EOD > $OUTFILE
# Used to define/realize users on Puppet-managed systems
#
class accounts inherits accounts::params {

EOD

while read LINE; do
  groupname=$(echo $LINE | awk '{print $1}')
  gid=$(echo $LINE | awk '{print $2}')
  echo "  @accounts::virtualgroups { '$groupname':" >> $OUTFILE
  echo "    gid             => $gid," >> $OUTFILE
  echo "  }" >> $OUTFILE
done < $GROUPFILE

echo >> $OUTFILE

while read LINE; do
  qgroups=""
  ensure="present"
  username=$(echo $LINE | awk '{print $1}')
  uid=$(echo $LINE | awk '{print $2}')
  groups=$(echo $LINE | awk '{print $3}')
  arr=$(echo $groups | tr "," "\n")
  for i in $arr ; do
    qgroups=$(echo \'$i\',$qgroups)
  done
  qgroups=$(echo "${qgroups%?}")
  comment=$(echo $LINE | awk '{$1=$2=$3=""; print substr($0,4)}')
  if echo $groups | grep -iq "disabled" ; then
    ensure="absent"
    comment="${comment}, disabled on $(date +%F)"
    qgroups=""
  fi
  echo "  @accounts::virtualuser { '$username':" >> $OUTFILE
  echo "    uid             =>  $uid," >> $OUTFILE
  echo "    ensure          =>  $ensure," >> $OUTFILE
  echo "    realname        =>  '$comment'," >> $OUTFILE
  echo "    groups          =>  [$qgroups]," >> $OUTFILE
  echo "    pass            =>  '!!'," >> $OUTFILE
  echo "  }" >> $OUTFILE
done < $USERFILE

cat << 'EOD' >> $OUTFILE

  #This is the only functional account that is created by puppet.
  @accounts::virtualuser { 'ansible':
    uid             =>  53,
    realname        => 'Ansible',
    pass            => '!!',
  }
#  @accounts::virtualuser { 'root':
#    uid             =>  0,
#    realname        => 'root',
#    system          => true,
#    groups          => ['bin','daemon','sys','adm','disk','wheel'],
#    shell           => '/bin/bash',
#    pass            => '$1$LjrKL324$Kd3kS6xWcM89eA70urd1H/',
#  }
}
EOD
