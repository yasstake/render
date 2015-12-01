
step1: build docker image

$ docker build -t mapbox .

step2: boot image

$ make boot-docker

step3: login

$ docker exec  -it <process id> bash
$ cd project

step3: createdb

$ make createdb

step4: download all






