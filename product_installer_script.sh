# Variables that must be adapted
PRODUCT_HOME=/home/aarellan/software/amq/amq-broker-7.1.0
SRC_DIR=/home/aarellan/software/amq

# Variables that should not change
INSTALLER=amq-broker-7.1.0-bin.zip

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
