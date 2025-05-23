#!/bin/bash

# Script permettant de chiffrer des manifest kubernetes via SOPS
# Le script parcourt le dossier courant et sous-dossiers pour trouver des fichiers avec l'extension .dec
# Les fichiers chiffrés sont sauvegardés avec l'extension .enc au lieu de .dec
# Il est possible de passer un argument pour changer le dossier courant, voir de donner un chemin vers un fichier
# test/
#   encrypt.sh
#   ovh/
#     dev/
#        secrets.yml.dec
#        other_secrets.yml.dec
#   mi/
#     pprod/secrets.yml.dec
#
# bash encrypt.sh => ovh/dev/secrets.yml.dec , ovh/dev/other_secrets.yml.dec , mi/pprod/secrets.yml.dec
# bash encrypt.sh ovh => ovh/dev/secrets.yml.dec , ovh/dev/other_secrets.yml.dec
# bash encrypt.sh ovh/dev/secrets.yml.dec => ovh/dev/secrets.yml.dec
#

export AGE_KEY=age1jmt0q9ruj8unlhdnqe2nqvtwfyjdynmlxjpjhmr9gl2hdwx7qusqreeurh

encrypt_path="."

if [ $# -gt 0 ]; then
  if [ -d "$1" ]; then
    encrypt_path="$1"
  elif [ -f "$1" ]; then
    encrypt_path="$1"
  else
    echo "Chemin non existant"
    exit 1
  fi
fi

for current_file in $(find ${encrypt_path} -name *.dec)
do
  filename="${current_file%.*}"
  extension="${current_file##*.}"

  if [ $extension == "dec" ]; then
    encrypted_file_path="${filename}.enc"
    echo "Encrypt file ${current_file} to ${encrypted_file_path}"
    sops -e --age $AGE_KEY --input-type yaml --output-type yaml --encrypted-suffix Templates "${current_file}" > "${encrypted_file_path}"
  fi
done
