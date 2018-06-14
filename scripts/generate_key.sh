#!/bin/sh

set -e

eval "$(jq -r '@sh "keys_dir=\(.keys_dir) id=\(.id)"')"

[ -d $keys_dir ] || mkdir -p $keys_dir

private_key_file="$keys_dir/$id"

[ -f $private_key_file ] || (
    wg genkey > $private_key_file
)

private_key=$(cat $private_key_file)
public_key=$(printf "$private_key" | wg pubkey)

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
exec jq -n \
    --arg private_key "$private_key" \
    --arg public_key "$public_key" \
    '{"private_key": $private_key, "public_key": $public_key}'