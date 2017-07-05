#! /opt/local/bin/bash
#
# Usage: wemo-cmd IP[:PORT] {ON|OFF|TOGGLE|STATE|STRENGTH|NAME}
#
# List of services from the Wemo switch: curl -q http://IP:PORT/eventservice.xml

# MAC address range for Belkin: C0:56:27:xx:xx:xx

function getPort()
{
	local port result
	for p in ${@}
	do
		curl -q -s -m1 "${IP}:${p}" > /dev/null && result="${p}" && break
	done
	echo "${result}"
}

if [ "${#}" -ne 2 ]
then
	echo "Usage: ${0##*/} IP[:PORT] {ON|OFF|TOGGLE|STATE|STRENGTH|NAME}"
	exit 1
fi

IP="${1%:*}"
PORT="${1##*:}"
PORT="${PORT/${IP}}"
CMD="${2^^}"

PORTS="49154 49152 49153 49155"
PORT=$(getPort "${PORT}" ${PORTS})

if [ ! "${PORT}" ]
then
	echo "Cannot find a port"
	exit
fi

STATES=("OFF" "ON")
declare -A ACTIONS
ACTIONS=([ON]="SetBinaryState" [OFF]="SetBinaryState" [TOGGLE]="GetBinaryState" [STATE]="GetBinaryState" [SIGNAL]="GetSignalStrength" [NAME]="GetFriendlyName")
ACTION="${ACTIONS[${CMD}]}"
if [ ! "${ACTION}" ]
then
	echo "Unknown command."
	exit
fi

URL="http://$IP:$PORT/upnp/control/basicevent1"
ACCEPT="Accept: "
CONTENT="Content-type: text/xml; charset=\"utf-8\""
SOAP="SOAPACTION: \"urn:Belkin:service:basicevent:1#${ACTION}\""

[ "${CMD}" = "OFF" ]
state=${?}
declare -A PARAMETERS
PARAMETERS=([SetBinaryState]="<BinaryState>${state}</BinaryState>" [GetBinaryState]="<BinaryState/>" [GetFriendlyName]="<friendlyname/>" [GetSignalStrength]="<GetSignalStrength/>")
XREQUEST="<?xml version=\"1.0\" encoding=\"utf-8\"?>
<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
    <s:Body>
    <u:${ACTION} xmlns:u=\"urn:Belkin:service:basicevent:1\">
        ${PARAMETERS[${ACTION}]}
    </u:${ACTION}>
    </s:Body>
</s:Envelope>"

XREPLY=$(curl -q -s -A 'none' -X POST -H "${ACCEPT}" -H "${CONTENT}" -H "${SOAP}" --data "${XREQUEST}" "${URL}")
echo "REPLY: ${XREPLY}"
state=$(xsltproc wemo.xslt - <<< "${XREPLY}")
echo state: "${state}"
echo "${STATES[${state}]}"
