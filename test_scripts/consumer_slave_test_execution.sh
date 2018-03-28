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

$AMQ_SLAVE_HOME/bin/artemis consumer --message-count 100 --url "tcp://localhost:6171" --destination queue://haQueue --sleep 1000 --verbose --user amq_dev_spoc_user --password amq_dev_spoc_pass
