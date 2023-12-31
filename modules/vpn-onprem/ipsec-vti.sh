#!/bin/bash
set -o nounset
set -o errexit

IP=$(which ip)

PLUTO_MARK_OUT_ARR=(${PLUTO_MARK_OUT//// })
PLUTO_MARK_IN_ARR=(${PLUTO_MARK_IN//// })

VTI_TUNNEL_ID=${1}
VTI_REMOTE=${2}
VTI_LOCAL=${3}

LOCAL_IF="${PLUTO_INTERFACE}"
VTI_IF="vti${VTI_TUNNEL_ID}"
# AWS's MTU is 1446, so it's hardcoded
AWS_MTU="1446"
# ipsec overhead is 73 bytes, we need to compute new mtu.
VTI_MTU=$((AWS_MTU-73))

case "${PLUTO_VERB}" in
    up-client)
        ${IP} link add ${VTI_IF} type vti local ${PLUTO_ME} remote ${PLUTO_PEER} okey ${PLUTO_MARK_OUT_ARR[0]} ikey ${PLUTO_MARK_IN_ARR[0]}
        ${IP} addr add ${VTI_LOCAL} remote ${VTI_REMOTE} dev "${VTI_IF}"
        ${IP} link set ${VTI_IF} up mtu ${VTI_MTU}

        # Disable IPSEC Policy
        sysctl -w net.ipv4.conf.${VTI_IF}.disable_policy=1

        # Enable loosy source validation, if possible. Otherwise disable validation.
        sysctl -w net.ipv4.conf.${VTI_IF}.rp_filter=2 || sysctl -w net.ipv4.conf.${VTI_IF}.rp_filter=0

        # If you would like to use VTI for policy-based you shoud take care of routing by yourselv, e.x.
        #if [[ "${PLUTO_PEER_CLIENT}" != "0.0.0.0/0" ]]; then
        #    ${IP} r add "${PLUTO_PEER_CLIENT}" dev "${VTI_IF}"
        #fi
        ;;
    down-client)
        ${IP} tunnel del "${VTI_IF}"
        ;;
esac

# Enable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1

# Disable IPSEC Encryption on local net
sysctl -w net.ipv4.conf.${LOCAL_IF}.disable_xfrm=1
sysctl -w net.ipv4.conf.${LOCAL_IF}.disable_policy=1