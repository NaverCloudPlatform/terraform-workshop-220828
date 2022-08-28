#!/bin/bash

export NCLOUD_ACCESS_KEY=3e5Lic3oYZB9TxD7EiHf
export NCLOUD_SECRET_KEY=ysXVp4H0V7ED70y6n33upXXJ1QUTFU9DodFDIsel
export TF_VAR_access_key=$NCLOUD_ACCESS_KEY
export TF_VAR_secret_key=$NCLOUD_SECRET_KEY
export TF_LOG=ERROR
export TF_LOG_PATH="./terraform.log"

alias t=terraform