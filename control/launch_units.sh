#!/bin/bash

if [ -z "$FLEETCTL_TUNNEL" ]; then
    echo
    echo "You must set FLEETCTL_TUNNEL (a resolvable address to one of your CoreOS instances)"
    echo "e.g.:"
    echo "export FLEETCTL_TUNNEL=1.2.3.4"
    echo
    exit 1
fi

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH/units

echo "Starting services"
echo "================="
fleetctl start aws_credentials
fleetctl start logspout
fleetctl start skydns{,-registrator}
# fleetctl start consul{,-announce,-registrator}
fleetctl start vulcand{,.elb}@1
fleetctl start influxdb{.volumes,}@1
fleetctl start redis{.volumes,}@1
fleetctl start redis-lru{.volumes,}@1
fleetctl start docker-registry@{1..2}
sleep 30
fleetctl start docker-registry.vulcand_frontend
fleetctl start docker-registry.vulcand@{1..2}
fleetctl start influxdb.{create_db,vulcand_frontend}
fleetctl start influxdb.vulcand@1
fleetctl start cadvisor
fleetctl start sysinfo_influxdb
fleetctl start zookeeper{.placement,}@{1..5}
sleep 60
fleetctl start kafka{.volumes,}@{1..5}
fleetctl start elasticsearch{.volumes,}@{1..3}
sleep 60
fleetctl start kafka.create_topics
fleetctl start logstash@1
fleetctl start syslog_kafka
fleetctl start schema-registry@{1..2}
sleep 60
fleetctl start kafka-rest@{1..2}
