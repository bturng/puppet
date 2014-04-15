#!/bin/bash

USERFILE="useraccounts.txt"

prod="admins"

environment="prod"

for environment in "prod"; do
  rm ../files/ansible_${environment}.pub
  while read LINE; do
    name=$(echo ${LINE} | awk '{print $1}')
    groups=$(echo ${LINE} | awk '{print $3}')
    for group in $(echo ${groups} | sed 's/,/ /g'); do
      if [[ "${!environment}" =~ "$group" ]]; then
        if [[ -f ../files/${name}.pub ]]; then
          restrict=""
          if [ "${environment}" = "prod" ]; then
            restrict="from=\"dc1-ansible01.dc01.revsci.net\" "
          fi
          key=$(cat ../files/${name}.pub)
          echo "${restrict}${key}"  >> ../files/ansible_${environment}.pub
        fi
        break
      fi
    done
  done < ${USERFILE}
done
