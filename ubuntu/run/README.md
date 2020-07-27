```
vi ~/.ssh/config

Host 192.168.5*
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
```

### to join master node from node01
```
make token in master

JOIN_CMD=`kubeadm create token --print-join-command`

run the command
$JOIN_CMD 
```