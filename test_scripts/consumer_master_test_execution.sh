PRODUCT_HOME=/home/aarellan/software/amq/amq-broker-7.1.0
AMQ_INSTANCES=$PRODUCT_HOME/instances
AMQ_MASTER=master
AMQ_MASTER_HOME=$AMQ_INSTANCES/$AMQ_MASTER

$AMQ_MASTER_HOME/bin/artemis consumer --message-count 100 --url "tcp://localhost:6161" --destination queue://haQueue --sleep 1000 --verbose --user amq_dev_spoc_user --password amq_dev_spoc_pass
