# Red Hat AMQ 7 High Availability Shared Store - master/slave same server | different servers
Local installation of AMQ HA using shared store

## Introduction
Red Hat JBoss AMQ 7 provides fast, lightweight, and secure messaging for Internet-scale applications. AMQ 7 components use industry-standard message protocols and support a wide range of programming languages and operating environments. AMQ 7 gives you the strong foundation you need to build modern distributed applications. Multiple instances of AMQ 7 brokers can be grouped together to share message processing load. Each broker manages its own messages and connections and is connected to other brokers with "cluster bridges" that are used to send topology information, such as queues and consumers, as well as load balancing messages. AMQ 7 supports two different strategies for backing up a server: shared store and replication.

This is a demonstration of the new AMQ 7 shared store high availability feature.

## Overview
AMQ has two policies using different strategies to enable failover:

    Replication: The master and slave brokers synchronize data over the network.

    Shared-store: Master and slave brokers share the same location for their messaging data. 
   
When using a shared-store, both master and slave brokers share a single data directory using a shared file system. This data directory includes the paging directory, journal directory, large messages, and binding journal. A slave broker loads the persistent storage from the shared file system if the master broker disconnects from the cluster. Clients can connect to the slave broker and continue their sessions.

The advantage of shared-store high availability is that no replication occurs between the master and slave nodes. This means it does not suffer any performance penalties due to the overhead of replication during normal operation.

The disadvantage of shared-store replication is that it requires a shared file system. Consequently, when the slave broker takes over, it needs to load the journal from the shared-store which can take some time depending on the amount of data in the store.

This style of high availability differs from data replication in that it requires a shared file system which is accessible by both the master and slave nodes. Typically this is some kind of high performance Storage Area Network (SAN). It is not recommend you use Network Attached Storage (NAS). 

## What does this project provides?
This script is intended to be used for test or production environments where you have the following requirements:
- Cluster with 2 nodes (master / slave)
- Cluster security and additional settings configuration
- HA using shared store
- An **Admin** user
- Address/Queue security: An additional user with limited permissions. (Using properties, no certificates)
- AMQ tuning for: 
	- Message redelivery
	- Redelivery delay
	- Message expire
	- Dead letter address
	- Slow consumer handling
	- Paging
- Access to the console from localhost and from a remote host
- A configurable test suite: consumer and producer
- Uninstaller script
- Web Console port configuration
- Possibility to install with few changes multiple instances in the same host

## What are the scripts provided?
#### Product deployer
- product_installer_script.sh: deploy the AMQ 7 binary on the given location. It is a prerequisite before any other script is executed.
#### Installer scripts
The installer scripts allow you to deploy a master and a slave AMQ 7 HA. It can be done in the same host or in different hosts.
- master_installer_script: install the master
- slave_installer_script: install the slave
#### Uninstaller scripts
The uninstaller script allows you to remove the AMQ 7 HA installation for master and slave and the clean up the persistence.
- uninstaller_script.sh: uninstall the AMQ 7 instance(s) deployed on the host where is executed
- uninstaller_persistence_script.sh: uninstall the AMQ 7 persistence storage


## What is out of the box configurable?

## Prerequisites
The provided scripts can be used to install AMQ in 2 different ways:
- Master/Slave on the same machine: 1 machine with the prerequisites described below is required.
- Master/Slave on different machines: 2 machines with the prerequisites described below are required.

#### Hardware requirements
* Operating System
  * Mac OS X (10.8 or later) or
  * Windows 7 (SP1) or
  * Fedora (21 or later) or
  * Red Hat Enterprise Linux 7
* Memory: At least 2 GB+, preferred 4 GB

#### Software requirements

* Web Browser (preferably Chrome or Firefox)
* Git client -- [download here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* http://github.com access

For running JBoss AMQ 7 Broker

* **Java Runtime Engine (JRE) 1.8** --[download here](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
* LibAIO (Optional)

If installing from supported version of Red Hat Enterprise Linux you can use yum command to install pre-requisites.

```
$ sudo yum install java-1.8.0-openjdk-devel git
```

## Download

Git clone this repository to [GIT_SOURCE] and then change directory name to **amq-ha-shared-store** 

## Configuration

Please read carefully the following configuration setup.

As mentioned in a previous section. The master/slave can be configured in the same machine or in different machines, which requires specific configuration in each case.

### Master/Slave on the same machine
The following scripts must be adjusted:

#### master_installer_script.sh 
Set the correct variables:
- PRODUCT_HOME = location where the AMQ 7 broker will be installed
- SRC_DIR = location of the AMQ 7 installer "amq-broker-7.1.0-bin.zip"
- SHARED_FILESYSTEM = location of the shared file system used for master and slave. The characters must be escaped. 

#### slave_installer_script.sh
Set the correct variables:
- PRODUCT_HOME = location where the AMQ 7 broker will be installed
- SRC_DIR = location of the AMQ 7 installer "amq-broker-7.1.0-bin.zip"
- SHARED_FILESYSTEM = location of the shared file system used for master and slave. The characters must be escaped.

### Master/Slave on different machines  
The following scripts must be adjusted:

#### master_installer_script.sh 
Set the correct variables:
- PRODUCT_HOME = location where the AMQ 7 broker will be installed
- SRC_DIR = location of the AMQ 7 installer "amq-broker-7.1.0-bin.zip"
- SHARED_FILESYSTEM = location of the shared file system used for master and slave. The characters must be escaped.
- HOST_IP= IP of the host where the current AMQ instance is deployed
- MASTER_DEFAULT_PORT= port of the master AMQ instance
- SLAVE_DEFAULT_PORT= port of the slave AMQ instance
- SLAVE_IP_PORT= IP of the host where the slave AMQ instance is installed
- CONSOLE_PORT= the port of the web console
- CLUSTER_CONNECTION_NAME= the name of the cluster connection
- AMQ_MASTER= name of the current AMQ master instance. This allows to install multiple instances on the same host.  
- AMQ_SLAVE= name of the current AMQ slave instance. This allows to install multiple instances on the same host.

#### slave_installer_script.sh
Set the correct variables:
- PRODUCT_HOME = location where the AMQ 7 broker will be installed
- SRC_DIR = location of the AMQ 7 installer "amq-broker-7.1.0-bin.zip"
- SHARED_FILESYSTEM = location of the shared file system used for master and slave. The characters must be escaped.
- HOST_IP= IP of the host where the current AMQ instance is deployed
- MASTER_DEFAULT_PORT= port of the master AMQ instance
- SLAVE_DEFAULT_PORT= port of the slave AMQ instance
- MASTER_IP_PORT= the IP of the host where the master AMQ instance is installed
- CONSOLE_PORT= the port of the web console
- CLUSTER_CONNECTION_NAME= the name of the cluster connection
- AMQ_MASTER= name of the current AMQ master instance. This allows to install multiple instances on the same host.  
- AMQ_SLAVE= name of the current AMQ slave instance. This allows to install multiple instances on the same host.
Set the correct addresses and ports
- HOST_IP = [host] the host IP address
- MASTER_IP_PORT = [host]:[port] the IP address of the master node and the port of the AMQ installed on the master host. Default master port is: 61616

## Deployment prerequisites

- Download AMQ 7 Broker from Red Hat Developer Portal: --[download here](https://developers.redhat.com/products/amq/download/). In case of different servers, please proceed to install on each server.

- Place the downloaded amq zip ("amq-broker-7.1.0-bin.zip") in the installs directory **[SRC_DIR]**

- Prepared the shared file system 

## Deployment
The AMQ installation must be done following the steps below:

### Install the product
Configure the **product_installer_script.sh** and execute it:
1 -  Configure the following variables:
- PRODUCT_HOME = location where the AMQ 7 broker will be installed
- SRC_DIR = location of the AMQ 7 installer "amq-broker-7.1.0-bin.zip"
2 - Execute the script **product_installer_script.sh**
```
[GIT_SOURCE]/amq-ha-shared-store/product_installer_script.sh
```

### Master/Slave on same machine 

1 - Run script **master_installer_script.sh** on the host
```
[GIT_SOURCE]/amq-ha-shared-store/master_installer_script.sh
```
2 - Run script **slave_installer_script.sh** on the host
```
[GIT_SOURCE]/amq-ha-shared-store/slave_installer_script.sh
```

### Master/Slave on different machines 

1 - Run script **master_installer_script.sh** on master host
```
[GIT_SOURCE]/amq-ha-shared-store/master_installer_script.sh
```
2 - Run script **slave_installer_script.sh** on slave host
```
[GIT_SOURCE]/amq-ha-shared-store/slave_installer_script.sh
```

After successful deployment, you can test the cluster. 


## Test
### Master active 
#### Producing messages

To send messages to the master broker, execute the following script:

```
[GIT_SOURCE]/amq-ha-shared-store/test_scripts/create_queue_test.sh
[GIT_SOURCE]/amq-ha-shared-store/test_scripts/producer_master_test_execution.sh
```

#### Browse messages on Master

To check the messages were successfully send to the broker, check the queue in the broker web console.

* Open a web browser and navigate to the AMQ web console http://localhost:8161/hawtio
* In the left tree navigate to 127.0.0.1 > addresses > haQueue > queues > anycast > haQueue
* Click on *Browse* (refresh if necessary)

You will see the 10 messages send by the producer script.

#### Consuming messages

To consume messages from the master broker, execute the following script:

```
[GIT_SOURCE]/amq-ha-shared-store/test_scripts/consumer_master_test_execution.sh
```

### Slave active 
#### Producing messages

To send messages to the master broker, execute the following script:

```
[GIT_SOURCE]/amq-ha-shared-store/test_scripts/producer_slave_test_execution.sh
```

#### Browse messages on Master

To check the messages were successfully send to the broker, check the queue in the broker web console.

* Open a web browser and navigate to the AMQ web console http://localhost:8261/hawtio
* In the left tree navigate to 127.0.0.1 > addresses > haQueue > queues > anycast > haQueue
* Click on *Browse* (refresh if necessary)

You will see the 10 messages send by the producer script.

#### Consuming messages

To consume messages from the master broker, execute the following script:

```
[GIT_SOURCE]/amq-ha-shared-store/test_scripts/consumer_slave_test_execution.sh
```

## Uninstall

To uninstall the AMQ 7 HA installed with this project two uninstallers are provided.

1 - Execute first the **uninstaller_script.sh** to stop and uninstall the AMQ 7
2 - Configure and execute after (if required) the **uninstaller_persistence_script.sh** to delete the persistence.
2.1. - Check the variable **SHARED_FILESYSTEM** 

