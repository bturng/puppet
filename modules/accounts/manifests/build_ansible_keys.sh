#!/bin/bash

USERFILE="useraccounts.txt"

prod="admins leads devs"
staging="admins leads devs"

environment="staging"

for environment in "prod" "staging"; do
  rm ../files/ansible_${environment}.pub
  # read the next line from useraccounts.txt
  while read LINE; do
    name=$(echo ${LINE} | awk '{print $1}')
    groups=$(echo ${LINE} | awk '{print $3}')
    
    # Iterate through the groups to determine the ssh key should be included
    echo "Processing: $name ($groups)"
    for group in $(echo ${groups} | sed 's/,/ /g'); do
      if [[ "${!environment}" =~ "$group" ]]; then
        if [[ -f ../files/${name}.pub ]]; then
          restrict=""
          if [ "${environment}" = "prod" ]; then
            restrict=""
          fi
          key=$(cat ../files/${name}.pub)
          echo "${restrict}${key}"  >> ../files/ansible_${environment}.pub
        fi
        break
      fi
    done
  done < ${USERFILE}
done
