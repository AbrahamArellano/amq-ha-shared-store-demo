# Variables that must be adapted
PRODUCT_HOME=/home/aarellan/software/amq/amq-broker-7.1.0
SRC_DIR=/home/aarellan/software/amq
SHARED_FILESYSTEM=\/home\/aarellan\/software\/amq\/common_persistence
HOST_IP=192.168.42.177
MASTER_IP=192.168.42.177:61616

# Variables that should not change
INSTALLER=amq-broker-7.1.0-bin.zip

AMQ_SERVER_CONF=$PRODUCT_HOME/etc
AMQ_SERVER_BIN=$PRODUCT_HOME/bin
AMQ_INSTANCES=$PRODUCT_HOME/instances
AMQ_MASTER=master
AMQ_SLAVE=slave
AMQ_MASTER_HOME=$AMQ_INSTANCES/$AMQ_MASTER
AMQ_SLAVE_HOME=$AMQ_INSTANCES/$AMQ_SLAVE

AMQ_SHARED_PERSISTENCE_PAGING=$SHARED_FILESYSTEM\/paging
AMQ_SHARED_PERSISTENCE_BINDINGS=$SHARED_FILESYSTEM\/bindings
AMQ_SHARED_PERSISTENCE_JOURNAL=$SHARED_FILESYSTEM\/journal
AMQ_SHARED_PERSISTENCE_LARGE_MESSAGE=$SHARED_FILESYSTEM\/large-messages

LOCAL_IP=127.0.0.1
ALL_ADDRESSES=0.0.0.0

echo "  - Create Replicated Slave"
echo

sh $AMQ_SERVER_BIN/artemis create --no-autotune --shared-store --failover-on-shutdown --slave --user admin --password password --role admin --allow-anonymous y --clustered --host $LOCAL_IP --cluster-user clusterUser --cluster-password clusterPassword  --max-hops 1 --port-offset 100 $AMQ_INSTANCES/$AMQ_SLAVE

echo "  - Changing default slave clustering configuration"
echo
sed -i'' -e 's/<max-disk-usage>90<\/max-disk-usage>/<max-disk-usage>100<\/max-disk-usage>/' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e '/<broadcast-groups>/,/<\/discovery-groups>/d' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e "s/$LOCAL_IP/$ALL_ADDRESSES/" $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e "s/<name>$ALL_ADDRESSES/<name>$HOST_IP/" $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e "/<\/connector>/ a \
        <connector name=\"discovery-connector\">tcp://$MASTER_IP</connector>" $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e '/<\/failover-on-shutdown>/ a \
               <allow-failback>true</allow-failback>' $AMQ_SLAVE_HOME/etc/broker.xml		
sed -i'' -e 's/<discovery-group-ref discovery-group-name="dg-group1"\/>/<static-connectors>   <connector-ref>discovery-connector<\/connector-ref><\/static-connectors>/' $AMQ_SLAVE_HOME/etc/broker.xml

# Setting persistance changes
sed -i'' -e "s|.\/data\/paging|$AMQ_SHARED_PERSISTENCE_PAGING|" $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e "s|.\/data\/bindings|$AMQ_SHARED_PERSISTENCE_BINDINGS|" $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e "s|.\/data\/journal|$AMQ_SHARED_PERSISTENCE_JOURNAL|" $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e "s|.\/data\/large-messages|$AMQ_SHARED_PERSISTENCE_LARGE_MESSAGE|" $AMQ_SLAVE_HOME/etc/broker.xml

# Allowing access to the console from the IPs: "localhost" and host IP. This is required in case of remote access to the console.
echo "  - Adjust of the web console to listen all addresses"
echo
sed -i'' -e "s/localhost/0.0.0.0/" $AMQ_SLAVE_HOME/etc/bootstrap.xml

sed -i'' -e "/<\/allow-origin>/ a \
         \        <allow-origin>*:\/\/$HOST_IP*<\/allow-origin>   \ " $AMQ_SLAVE_HOME/etc/jolokia-access.xml

echo "  - Start up AMQ Slave in the background"
echo
sh $AMQ_SLAVE_HOME/bin/artemis-service start

sleep 5

COUNTER=5
#===Test if the broker is ready=====================================
echo "  - Testing broker,retry when not ready"
while true; do
    if [ $(sh $AMQ_SLAVE_HOME/bin/artemis-service status | grep "running" | wc -l ) -ge 1 ]; then
        break
    fi

    if [  $COUNTER -le 0 ]; then
    	echo ERROR, while starting broker, please check your settings.
    	break
    fi
    let COUNTER=COUNTER-1
    sleep 2
done
#===================================================================




