#!/bin/bash
# write by Weiqiong Chen
# func: generate kds for big data day

# must provide right parameter to run this script
if [ $# != 2 ]; then
    echo "USAGE: $0 stream_name transaction_date"
    echo "Example: $0 kds-lab4 2020-09-05"
    exit 1
fi

# address: A1001 - A2084 , customer: U1001 - U2084 , product: P1001 - P1100
# get parameter
region_name="ap-southeast-1"
stream_name=$1
transaction_date=$2

# write log
function write_log() {
    echo "$(date +%FT%TZ) ## $0 ## $1" >>./lab4-${stream_name}-$(date +%F).log
}

# get random number between $1 and $2
function random_range() {
    echo $(($(($RANDOM % $(($1 - $2)))) + $1))
}

# generate next transaction id
function next_tid() {
    echo $(($1 + 1))
}

# get cacha data
function get_cache() {
    echo $(echo hget $1 $2 | redis-cli)
}

# generate next transaction no
function next_tno() {
    echo D$(LC_CTYPE=C tr -dc 'A-HJ-NPR-Za-km-z2-9' </dev/urandom | head -c 3)$(date +%Y%m%d%H%M%S)
}

# define transaction start id
beg_tid="1"

# run forever
while true; do
    # random tranasaction this time
    t_thistime=$(random_range 1 3)
    write_log "----------"
    write_log "#### Generate ${t_thistime} Transactions this time."
    i=1
    while [[ $i -le ${t_thistime} ]]; do
        get_tid=D$(next_tid ${beg_tid})
        get_tno=$(next_tno)
        get_uno=U$(random_range 1001 2084)
        get_pno=P$(random_range 1001 1100)
        get_tnum=$(random_range 2 50)
        get_uname=$(get_cache $get_uno "name")
        get_umobile=$(get_cache "$get_uno" "mobile")
        get_ano=$(get_cache "$get_uno" "address")
        #write_log "#### get cache of get_ano: $get_ano "
        get_acity=$(get_cache "$get_ano" "city")
        #write_log "#### get cache of get_acity: $get_acity "
        get_aname=$(get_cache "$get_ano" "address")
        get_pclass=$(get_cache "$get_pno" "class")
        get_pname=$(get_cache "$get_pno" "name")
        get_pname=$(echo $get_pname | sed -e 's/[[:space:]][[:space:]]*/-/g')
        get_pprice=$(get_cache "$get_pno" "price")
        get_pprice=$(echo $get_pprice | sed -e 's/.00//g')
        get_total=$(expr $get_pprice \* $get_tnum)
        get_uptime=$(date +%FT%TZ)
        #data="{\"tid\":\"${get_tid}\",\"tno\":\"${get_tno}\",\"tdate\":\"${transaction_date}\",\"uno\":\"${get_uno}\",\"pno\":\"${get_pno}\",\"tnum\":\"${get_tnum}\",\"uname\":\"${get_uname}\",\"umobile\":\"${get_umobile}\",\"ano\":\"${get_ano}\",\"acity\":\"${get_acity}\",\"aname\":\"${get_aname}\",\"pclass\":\"${get_pclass}\",\"pname\":\"${get_pname}\",\"price\":${get_pprice},\"tuptime\":\"${get_tuptime}\"}"
        data="{\"tid\":\"${get_tid}\",\"tno\":\"${get_tno}\",\"tdate\":\"${transaction_date}\",\"uno\":\"${get_uno}\",\"pno\":\"${get_pno}\",\"tnum\":${get_tnum},\"uname\":\"${get_uname}\",\"umobile\":\"${get_umobile}\",\"ano\":\"${get_ano}\",\"acity\":\"${get_acity}\",\"aname\":\"${get_aname}\",\"pclass\":\"${get_pclass}\",\"pname\":\"${get_pname}\",\"pprice\":${get_pprice},\"total\":${get_total},\"tuptime\":\"${get_uptime}\"}"
        write_log "data: $data"
        # write_log "aws kinesis put-record --stream-name ${stream_name} --data $data --partition-key ${pkey} --region ${region_name}"
        aws kinesis put-record --stream-name ${stream_name} --data $data --partition-key ${get_tno} --region ${region_name} >>./lab4-${stream_name}-$(date +%F).log 2>&1
        beg_tid=${beg_tid}+1
        i=$i+1
    done
    # random slepp
    slp=$(random_range 1 3)
    write_log "#### Sleep $slp seconds for next time start."
    sleep $slp
done
