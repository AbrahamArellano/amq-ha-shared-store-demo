PRODUCT_HOME=/home/aarellan/software/amq/amq-broker-7.1.0

echo "  - Stop all existing AMQ processes..."
echo
jps -lm | grep artemis | awk '{print $1}' | if [[ $OSTYPE = "linux-gnu" ]]; then xargs -r kill -SIGTERM; else xargs kill -SIGTERM; fi


# Remove old install if it exists.
if [ -x $PRODUCT_HOME ]; then
		echo "  - existing $PRODUCT install detected..."
		echo
		echo "  - moving existing $PRODUCT aside..."
		echo
		rm -rf $PRODUCT_HOME
fi

if [ -x $PRODUCT_HOME.OLD ]; then
		echo "  - existing $PRODUCT install detected..."
		echo
		echo "  - moving existing $PRODUCT aside..."
		echo
		rm -rf $PRODUCT_HOME.OLD
fi

rm -rf /home/aarellan/software/amq/common_persistence/paging
rm -rf /home/aarellan/software/amq/common_persistence/bindings
rm -rf /home/aarellan/software/amq/common_persistence/journal
rm -rf /home/aarellan/software/amq/common_persistence/large-messages