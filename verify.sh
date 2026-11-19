#!/bin/bash

if [ $# -ne 1 ]; then
   echo "Usage: $0 <hosts_file>" >&2
   exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
  echo "Error: file '$FILE' does not exist." >&2
  exit 2
fi

verify-IP() {
  name=$1
  file_ip=$(grep " $name$" "$FILE" | cut -d' ' -f1)
  dns_ips=$(nslookup "$name" | grep Address | grep -v '#' | cut -d' ' -f2)

  if [ -z "$dns_ips" ]; then
      return 2
   fi

  if echo "$dns_ips" | grep -qx "$file_ip"; then
     return 0
  fi

  echo "Bogus IP for $name in \$HOME/etc/hosts !"
   return 1
}
 
while read -r ip name _; do
  if [ -z "$ip" ] || [[ "$ip" == \#* ]] || [[ "$ip" == *:* ]] ||  [ -z "$name" ]; then
     continue
  fi

  verify-IP "$name"
done < "$HOME/etc/hosts"
