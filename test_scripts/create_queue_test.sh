PRODUCT_HOME=/home/aarellan/software/amq/amq-broker-7.1.0
AMQ_INSTANCES=$PRODUCT_HOME/instances
AMQ_MASTER=master
AMQ_MASTER_HOME=$AMQ_INSTANCES/$AMQ_MASTER

echo "  - Create haQueue on master broker "
echo
sh $AMQ_MASTER_HOME/bin/artemis queue create --auto-create-address --address haQueue --name haQueue --preserve-on-no-consumers --durable --anycast  --user amq_dev_spoc_user --password amq_dev_spoc_pass --url tcp://localhost:6161
