PRODUCT_HOME=/home/aarellan/software/amq/amq-broker-7.1.0
SRC_DIR=/home/aarellan/software/amq
INSTALLER=amq-broker-7.1.0-bin.zip
SHARED_FILESYSTEM=/home/aarellan/software/amq/amq_share

AMQ_SERVER_CONF=$PRODUCT_HOME/etc
AMQ_SERVER_BIN=$PRODUCT_HOME/bin
AMQ_INSTANCES=$PRODUCT_HOME/instances
AMQ_MASTER=master
AMQ_SLAVE=slave
AMQ_MASTER_HOME=$AMQ_INSTANCES/$AMQ_MASTER
AMQ_SLAVE_HOME=$AMQ_INSTANCES/$AMQ_SLAVE

echo "  - Create haQueue on master broker "
echo
sh $AMQ_MASTER_HOME/bin/artemis queue create --auto-create-address --address haQueue --name haQueue --preserve-on-no-consumers --durable --anycast --url tcp://localhost:61616