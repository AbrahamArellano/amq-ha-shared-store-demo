# Variables that must be adapted
PRODUCT_HOME=/home/aarellan/software/amq/amq-broker-7.1.0
SRC_DIR=/home/aarellan/software/amq
SHARED_FILESYSTEM=\/home\/aarellan\/software\/amq\/common_persistence
# Variables that must be adapted (only master/slave in different machines)
HOST_IP=192.168.42.177
SLAVE_IP_PORT=192.168.42.177:61716

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

chmod +x $SRC_DIR/*.zip

echo "  - Stop all existing AMQ processes..."
echo
jps -lm | grep artemis | awk '{print $1}' | if [[ $OSTYPE = "linux-gnu" ]]; then xargs -r kill -SIGTERM; else xargs kill -SIGTERM; fi

# make some checks first before proceeding.
if [[ -r $SRC_DIR/$INSTALLER || -L $SRC_DIR/$INSTALLER ]]; then
		echo "  - $PRODUCT is present..."
		echo
else
		echo Need to download $PRODUCT package from the Customer Support Portal
		echo and place it in the $SRC_DIR directory to proceed...
		echo
		exit
fi

# Remove old install if it exists.
if [ -x $PRODUCT_HOME ]; then
		echo "  - existing $PRODUCT install detected..."
		echo
		echo "  - moving existing $PRODUCT aside..."
		echo
		rm -rf $PRODUCT_HOME.OLD
		mv $PRODUCT_HOME $PRODUCT_HOME.OLD
fi

# Run installer.
echo "  - Unpacking $PRODUCT $VERSION"
echo
mkdir -p $PRODUCT_HOME && unzip -q -d $PRODUCT_HOME/.. $SRC_DIR/$INSTALLER

echo "  - Making sure 'AMQ' for server is executable..."
echo
chmod u+x $PRODUCT_HOME/bin/artemis

echo "  - Create Replicated Master"
echo

sh $AMQ_SERVER_BIN/artemis create --no-autotune --shared-store --failover-on-shutdown --user admin --password password --role admin --allow-anonymous y --clustered --host $LOCAL_IP --cluster-user clusterUser --cluster-password clusterPassword  --max-hops 1 $AMQ_INSTANCES/$AMQ_MASTER

echo "  - Changing default master clustering configuration"
echo
sed -i'' -e 's/<max-disk-usage>90<\/max-disk-usage>/<max-disk-usage>100<\/max-disk-usage>/' $AMQ_MASTER_HOME/etc/broker.xml
sed -i'' -e '/<broadcast-groups>/,/<\/discovery-groups>/d' $AMQ_MASTER_HOME/etc/broker.xml
sed -i'' -e "s/$LOCAL_IP/$ALL_ADDRESSES/" $AMQ_MASTER_HOME/etc/broker.xml
sed -i'' -e "s/<name>$ALL_ADDRESSES/<name>$HOST_IP/" $AMQ_MASTER_HOME/etc/broker.xml
sed -i'' -e "/<\/connector>/ a \
        <connector name=\"discovery-connector\">tcp://$SLAVE_IP_PORT</connector>" $AMQ_MASTER_HOME/etc/broker.xml		
sed -i'' -e 's/<discovery-group-ref discovery-group-name="dg-group1"\/>/<static-connectors>   <connector-ref>discovery-connector<\/connector-ref><\/static-connectors>/' $AMQ_MASTER_HOME/etc/broker.xml

# Setting persistance changes
sed -i'' -e "s|.\/data\/paging|$AMQ_SHARED_PERSISTENCE_PAGING|" $AMQ_MASTER_HOME/etc/broker.xml
sed -i'' -e "s|.\/data\/bindings|$AMQ_SHARED_PERSISTENCE_BINDINGS|" $AMQ_MASTER_HOME/etc/broker.xml
sed -i'' -e "s|.\/data\/journal|$AMQ_SHARED_PERSISTENCE_JOURNAL|" $AMQ_MASTER_HOME/etc/broker.xml
sed -i'' -e "s|.\/data\/large-messages|$AMQ_SHARED_PERSISTENCE_LARGE_MESSAGE|" $AMQ_MASTER_HOME/etc/broker.xml

# Allowing access to the console from the IPs: "localhost" and host IP. This is required in case of remote access to the console.
echo "  - Adjust of the web console to listen all addresses"
echo
sed -i'' -e "s/localhost/0.0.0.0/" $AMQ_MASTER_HOME/etc/bootstrap.xml

sed -i'' -e "/<\/allow-origin>/ a \
         \        <allow-origin>*:\/\/$HOST_IP*<\/allow-origin>   \ " $AMQ_MASTER_HOME/etc/jolokia-access.xml

echo "  - Start up AMQ Master in the background"
echo
sh $AMQ_MASTER_HOME/bin/artemis-service start

sleep 5

COUNTER=5
#===Test if the broker is ready=====================================
echo "  - Testing broker,retry when not ready"
while true; do
    if [ $(sh $AMQ_MASTER_HOME/bin/artemis-service status | grep "running" | wc -l ) -ge 1 ]; then
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

