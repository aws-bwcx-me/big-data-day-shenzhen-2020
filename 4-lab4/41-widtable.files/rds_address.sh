#!/bin/bash
# write by Weiqiong Chen
# func: load data to redis

#Write Log
function write_log() {
    echo "$(date +%FT%TZ) ## $0 ## $1" >>./logs-address-$(date +%F).log
}

# start cache data line by line
write_log "####################Start of cache address"
rm -f ./tbl_address.rds >/dev/null 2>&1
if [ -e ./tbl_address.csv ]; then
    while read line; do
        ano=$(echo $line | awk -F '","' {'print $2}')
        city=$(echo $line | awk -F '","' {'print $3}')
		address=$(echo $line | awk -F '","' {'print $4}')
        # set cache key and value
        echo "hset ${ano} ano '${ano}'" >>./tbl_address.rds
        echo "hset ${ano} city '${city}'" >>./tbl_address.rds
        echo "hset ${ano} address '${address}'" >>./tbl_address.rds
    done <./tbl_address.csv
    write_log "## load of ./tbl_address.rds"
    unix2dos ./tbl_address.rds
    cat ./tbl_address.rds | redis-cli --pipe
fi

rm -f ./tbl_address.rds >/dev/null 2>&1
write_log "####################End of cache address"
