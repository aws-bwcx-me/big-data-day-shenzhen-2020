#!/bin/bash
# write by Weiqiong Chen
# func: load data to redis

#Write Log
function write_log() {
    echo "$(date +%FT%TZ) ## $0 ## $1" >>./logs-product-$(date +%F).log
}

# start cache data line by line
write_log "####################Start of cache product"
rm -f ./tbl_product.rds >/dev/null 2>&1
if [ -e ./tbl_product.csv ]; then
    while read line; do
        pno=$(echo $line | awk -F '","' {'print $2}')
        class=$(echo $line | awk -F '","' {'print $3}')
        name=$(echo $line | awk -F '","' {'print $4}')
        price=$(echo $line | awk -F '","' {'print $5}')
        # set cache key and value
        echo "hset ${pno} pno '${pno}'" >>./tbl_product.rds
        echo "hset ${pno} class '${class}'" >>./tbl_product.rds
        echo "hset ${pno} name '${name}'" >>./tbl_product.rds
        echo "hset ${pno} price '${price}'" >>./tbl_product.rds
        echo "hset ${pno} stock 1000" >>./tbl_product.rds
    done <./tbl_product.csv
    write_log "## load of ./tbl_product.rds"
    unix2dos ./tbl_product.rds
    cat ./tbl_product.rds | redis-cli --pipe
fi

rm -f ./tbl_product.rds >/dev/null 2>&1
write_log "####################End of cache product"
