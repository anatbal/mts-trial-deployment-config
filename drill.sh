#bin/bash

while getopts t:r:f: flag
do
    case "${flag}" in
        t) trial_name=${OPTARG};;
        r) region=${OPTARG};;
        f) failover_group=${OPTARG};;
    esac
done
az webapp stop -n "as-$trial_name-sc-gateway-$failover_group" -g "rg-trial-$trial_name-$region"
