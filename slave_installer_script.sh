# Variables that must be adapted
PRODUCT_HOME=/home/aarellan/software/amq/amq-broker-7.1.0
SRC_DIR=/home/aarellan/software/amq
SHARED_FILESYSTEM=\/home\/aarellan\/software\/amq\/common_persistence
# Variables that must be adapted (only master/slave in different machines)
HOST_IP=192.168.122.1
MASTER_DEFAULT_PORT=6161
SLAVE_DEFAULT_PORT=6171
MASTER_IP_PORT=192.168.122.1:$MASTER_DEFAULT_PORT

# Variables that should not change
CLUSTER_CONNECTION_NAME=amq_cluster_configuration
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

sh $AMQ_SERVER_BIN/artemis create --no-autotune --shared-store --failover-on-shutdown --slave --user admin --password password --role admin --allow-anonymous y --clustered --host $LOCAL_IP --default-port $SLAVE_DEFAULT_PORT --cluster-user amq_cluster_user --cluster-password amq_cluster_password --max-hops 1 --require-login y $AMQ_INSTANCES/$AMQ_SLAVE

echo "  - Changing default slave clustering configuration"
echo
sed -i'' -e 's/<max-disk-usage>90<\/max-disk-usage>/<max-disk-usage>100<\/max-disk-usage>/' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e '/<broadcast-groups>/,/<\/discovery-groups>/d' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e "s/$LOCAL_IP/$ALL_ADDRESSES/" $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e "s/<name>$ALL_ADDRESSES/<name>$HOST_IP/" $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e "/<\/connector>/ a \
        \        <connector name=\"discovery-connector\">tcp://$MASTER_IP_PORT</connector>" $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e '/<\/failover-on-shutdown>/ a \
               <allow-failback>true</allow-failback>' $AMQ_SLAVE_HOME/etc/broker.xml		
sed -i'' -e 's/<discovery-group-ref discovery-group-name="dg-group1"\/>/<static-connectors>   \n            <connector-ref>discovery-connector<\/connector-ref> \n            <\/static-connectors> /' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e "s/my-cluster/$CLUSTER_CONNECTION_NAME/" $AMQ_SLAVE_HOME/etc/broker.xml

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

# Create role
echo "  -Creating role spoc_role "
sed -i'' -e "/admin = admin/ a \
        spoc_role=amq_dev_spoc_user\ " $AMQ_SLAVE_HOME/etc/artemis-roles.properties	
echo

# Create user 
echo "  -Creating user amq_dev_spoc_user "
echo
sh $AMQ_SLAVE_HOME/bin/artemis user add --user amq_dev_spoc_user --password amq_dev_spoc_pass --role spoc_role
echo

# Setup security permissions
sed -i'' -e 's/"createNonDurableQueue" roles="admin"/"createNonDurableQueue" roles="admin, spoc_role" / ' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e 's/"deleteNonDurableQueue" roles="admin"/"deleteNonDurableQueue" roles="admin, spoc_role" / ' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e 's/"createDurableQueue" roles="admin"/"createDurableQueue" roles="admin, spoc_role" / ' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e 's/"deleteDurableQueue" roles="admin"/"deleteDurableQueue" roles="admin, spoc_role" / ' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e 's/"createAddress" roles="admin"/"createAddress" roles="admin, spoc_role" / ' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e 's/"deleteAddress" roles="admin"/"deleteAddress" roles="admin, spoc_role" / ' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e 's/"consume" roles="admin"/"consume" roles="admin, spoc_role" / ' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e 's/"browse" roles="admin"/"browse" roles="admin, spoc_role" / ' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e 's/"send" roles="admin"/"send" roles="admin, spoc_role" / ' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e 's/"manage" roles="admin"/"manage" roles="admin, spoc_role" / ' $AMQ_SLAVE_HOME/etc/broker.xml

### Handling Message Exceptions

## Message redelivery
# Redelivery delay
# Message expire
# Dead letter address
# Slow consumer handling
# Paging
sed -i'' -e 's/<redelivery-delay>0/<redelivery-delay>5000/ ' $AMQ_SLAVE_HOME/etc/broker.xml
sed -i'' -e 's/<max-size-bytes>-1/<max-size-bytes>1GB/ ' $AMQ_SLAVE_HOME/etc/broker.xml

sed -i'' -e "/<address-setting match=\"#\">/ a \
         \            <redelivery-delay-multiplier>2</redelivery-delay-multiplier> \n\
		 \   <max-redelivery-delay>50000</max-redelivery-delay> \n\
		 \   <expiry-delay>600000</expiry-delay> \n\
		 \   <max-delivery-attempts>5</max-delivery-attempts> \n\
		 \   <slow-consumer-policy>NOTIFY</slow-consumer-policy> \n\
		 \   <slow-consumer-check-period>10</slow-consumer-check-period> \n\
		 \   <slow-consumer-threshold>10</slow-consumer-threshold> \n\
		 \   <page-size-bytes>400Mb</page-size-bytes> \n\
		 \   <page-max-cache-size>6</page-max-cache-size> \n\
		 \ " $AMQ_SLAVE_HOME/etc/broker.xml
	 
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

