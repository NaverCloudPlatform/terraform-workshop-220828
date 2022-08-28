#!/bin/bash


ACCESSKEY=${access_key}				# access key id (from portal or Sub Account)
SECRETKEY=${secret_key}				# secret key (from portal or Sub Account)
TIMESTAMP=$(echo $(($(date +%s%N)/1000000)))
METHOD="POST"
URL="https://cloudloganalytics.apigw.ntruss.com"
URI="/api/v1/vpc/servers/collecting-infos"

nl=$'\\n'
SIG="$${METHOD}"' '"$${URI}"$${nl}
SIG+="$${TIMESTAMP}"$${nl}
SIG+="$${ACCESSKEY}"
SIGNATURE=$(echo -n -e "$${SIG}"|iconv -t utf8 |openssl dgst -sha256 -hmac $${SECRETKEY} -binary|openssl enc -base64)


get_payload() {
   cat << EOF
{
  "collectingInfos": [
%{ for value in values(servers) ~}
    {
        "logPath": "/var/log/messages",
        "logTemplate": "SYSLOG",
        "logType": "SYSLOG",
        "servername": "${value.name}",
        "osType": "CentOS 7",
        "ip": "${value.private_ip}",
        "instanceNo": ${value.id}
    },
    {
        "logPath": "/var/log/secure*",
        "logTemplate": "Security",
        "logType": "security_log",
        "servername": "${value.name}",
        "osType": "CentOS 7",
        "ip": "${value.private_ip}",
        "instanceNo": ${value.id}
    }%{ if value != element(values(servers), length(values(servers))-1) },%{ endif }
%{ endfor ~}
  ]
}
EOF
}

RES=$(curl -X $${METHOD} "$${URL}$${URI}" \
-H "accept: application/json" \
-H "x-ncp-region_code: KR" \
-H "x-ncp-region_no: 1" \
-H "Content-Type: application/json" \
-H "x-ncp-iam-access-key: $${ACCESSKEY}" \
-H "x-ncp-apigw-timestamp: $${TIMESTAMP}" \
-H "x-ncp-apigw-signature-v2: $${SIGNATURE}" \
-d "$(get_payload)")

yum install -y jq
CONFIGKEY=$(echo $RES | jq -r '.result')

cat << EOF >> playbook.yml
---
- name: install cla agent
  hosts:
  - all
  tasks:
  - shell: "curl -s http://cm.vcla.ncloud.com/setUpClaVPC/$${CONFIGKEY} | sh"
EOF

ansible-playbook -i /root/inventory.ini playbook.yml
rm -f playbook.yml


