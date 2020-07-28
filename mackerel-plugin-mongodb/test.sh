#!/bin/sh

prog=$(basename $0)
if ! [[ -S /var/run/docker.sock ]]
then
	echo "$prog: there are no running docker" >&2
	exit 2
fi

cd $(dirname $0)
plugin=$(basename $(pwd))
if ! which -s $plugin
then
	echo "$prog: $plugin is not installed" >&2
	exit 2
fi

user=root
password=passpass
port=27017
docker run -d \
	--name test-$plugin \
	-p $port:$port \
	-e MONGO_INITDB_ROOT_USERNAME=$user \
	-e MONGO_INITDB_ROOT_PASSWORD=$password \
	mongo:3-xenial
trap 'docker stop test-$plugin; docker rm test-$plugin; exit' EXIT
sleep 10

if $plugin -port $port -username=$user -password $password >/dev/null 2>&1
then
	echo OK
else
	echo FAIL
fi
