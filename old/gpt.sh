#!/bin/bash

# Function to convert IP to decimal
ip_to_decimal() {
    local ip=$1
    local IFS=.
    read -r i1 i2 i3 i4 <<< "$ip"
    echo "$((i1 * 256**3 + i2 * 256**2 + i3 * 256 + i4))"
}

# Function to convert decimal to IP
decimal_to_ip() {
    local dec=$1
    local i1=$(( (dec >> 24) & 255 ))
    local i2=$(( (dec >> 16) & 255 ))
    local i3=$(( (dec >> 8) & 255 ))
    local i4=$(( dec & 255 ))
    echo "$i1.$i2.$i3.$i4"
}

# Function to calculate IP range
calculate_ip_range() {
    local cidr=$1
    local ip=${cidr%/*}
    local prefix=${cidr#*/}
    local ip_decimal=$(ip_to_decimal "$ip")
    
    local host_bits=$(( 32 - prefix ))
    local network_mask=$(( (2**32 - 1) << host_bits & 0xFFFFFFFF ))
    local network_decimal=$(( ip_decimal & network_mask ))
    local broadcast_decimal=$(( network_decimal | ~network_mask & 0xFFFFFFFF ))

    local start_ip_decimal=$(( network_decimal + 1 ))
    local end_ip_decimal=$(( broadcast_decimal - 1 ))

    echo "Network IP: $(decimal_to_ip $network_decimal)"
    echo "Start IP: $(decimal_to_ip $start_ip_decimal)"
    echo "End IP: $(decimal_to_ip $end_ip_decimal)"
    echo "Broadcast IP: $(decimal_to_ip $broadcast_decimal)"
    
    echo "List of all IP addresses in the range:"
    for ((i=start_ip_decimal; i<=end_ip_decimal; i++)); do
        decimal_to_ip $i
    done
}

# Main script
if [ $# -ne 1 ]; then
    echo "Usage: $0 <CIDR>"
    exit 1
fi

calculate_ip_range "$1"
