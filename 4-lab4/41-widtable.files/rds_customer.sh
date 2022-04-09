#!/bin/bash
# write by Weiqiong Chen
# func: load data to redis

#Write Log
function write_log() {
    echo "$(date +%FT%TZ) ## $0 ## $1" >>./logs-customer-$(date +%F).log
}

# start cache data line by line
write_log "####################Start of cache customer"
rm -f ./tbl_customer.rds >/dev/null 2>&1
if [ -e ./tbl_customer.csv ]; then
    while read line; do
        uno=$(echo $line | awk -F '","' {'print $2}')
        name=$(echo $line | awk -F '","' {'print $3}')
		mobile=$(echo $line | awk -F '","' {'print $4}')
        address=$(echo $line | awk -F '","' {'print $5}')
        # set cache key and value
        echo "hset ${uno} uno '${uno}'" >>./tbl_customer.rds
        echo "hset ${uno} name '${name}'" >>./tbl_customer.rds
        echo "hset ${uno} mobile '${mobile}'" >>./tbl_customer.rds
        echo "hset ${uno} address '${address}'" >>./tbl_customer.rds
    done <./tbl_customer.csv
    write_log "## load of ./tbl_customer.rds"
    unix2dos ./tbl_customer.rds
    cat ./tbl_customer.rds | redis-cli --pipe
fi

rm -f ./tbl_customer.rds >/dev/null 2>&1
write_log "####################End of cache customer"
