# Terraform을 이용하여 Naver Cloud Platform에 Infra를 Provisioning하고, Cloud Log Analytics와 연계하는 방안

## 사전 작업

1. `config.sh.sample`을 `config.sh`로 rename 하고 본인의 access_key와 secret_key를 기입
``` bash
> mv config.sh.sample config.sh
> vi config.sh
export NCLOUD_ACCESS_KEY=3e5xxxxxxxxxxxxxiHf
export NCLOUD_SECRET_KEY=ysXxxxxxxxxxxxxxxxxxxxxxxxxxDIsel
```
> Windows의 경우 export -> set으로 변경하여 환경변수 등록

2. `config.sh`을 source하여 환경변수 등록
``` bash
> source config.sh
> env
TF_VAR_access_key=3e5xxxxxxxxxxxxxiHf
TF_VAR_secret_key=ysXxxxxxxxxxxxxxxxxxxxxxxxxxDIsel
```

3. infra -> provisioner의 순서로 terraform 적용