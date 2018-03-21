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

Git clone this repository and then change directory to **amq-ha-shared-store**

## Configuration

Please read carefully the following configuration setup.

As mentioned in a previous section. The master/slave can be configured in the same machine or in different machines, which requires specific configuration in each case.

### Master/Slave on the same machine
The following scripts must be adjusted:

#### master_installer_script.sh 
Set the correct directories for the variables:
- PRODUCT_HOME = location where the AMQ 7 broker will be installed
- SRC_DIR = location of the AMQ 7 installer "amq-broker-7.1.0-bin.zip"
- SHARED_FILESYSTEM = location of the shared file system used for master and slave.

#### slave_installer_script.sh
Set the correct directories for the variables:
- PRODUCT_HOME = location where the AMQ 7 broker will be installed
- SRC_DIR = location of the AMQ 7 installer "amq-broker-7.1.0-bin.zip"
- SHARED_FILESYSTEM = location of the shared file system used for master and slave.

### Master/Slave on different machines  
The following scripts must be adjusted:

#### master_installer_script.sh 
Set the correct directories for the variables:
- PRODUCT_HOME = location where the AMQ 7 broker will be installed
- SRC_DIR = location of the AMQ 7 installer "amq-broker-7.1.0-bin.zip"
- SHARED_FILESYSTEM = location of the shared file system used for master and slave. This is a shared file system which is accessible by both the master and slave nodes. Typically this is some kind of high performance Storage Area Network (SAN). It is not recommend you use Network Attached Storage (NAS). 

Set the correct addresses and ports
- HOST_IP = [host] the host IP address
- SLAVE_IP_PORT = [host]:[port] the IP address of the slave node and the port of the AMQ installed on the slave host. The standard configuration has an port-offset of 100, which increase the port value during installation of the slave. Default slave port is: 61716 

#### slave_installer_script.sh
Set the correct directories for the variables:
- PRODUCT_HOME = location where the AMQ 7 broker will be installed
- SRC_DIR = location of the AMQ 7 installer "amq-broker-7.1.0-bin.zip"
- SHARED_FILESYSTEM = location of the shared file system used for master and slave. This is a shared file system which is accessible by both the master and slave nodes. Typically this is some kind of high performance Storage Area Network (SAN). It is not recommend you use Network Attached Storage (NAS).

Set the correct addresses and ports
- HOST_IP = [host] the host IP address
- MASTER_IP_PORT = [host]:[port] the IP address of the master node and the port of the AMQ installed on the master host. Default master port is: 61616

## Deployment prerequisites

- Download AMQ 7 Broker from Red Hat Developer Portal: --[download here](https://developers.redhat.com/products/amq/download/). In case of different servers, please proceed to install on each server.

- Place the downloaded amq zip ("amq-broker-7.1.0-bin.zip") in the installs directory **[master|slave]_installer_script.sh/SRC_DIR**

- Prepared the shared file system 

## Deployment
The AMQ installation must be done following the steps below:

### Master/Slave on same machine 

#### 1 - Run script **master_installer_script.sh** on host
#### 2 - Run script **slave_installer_script.sh** on host

### Master/Slave on different machines 

#### 1 - Run script **master_installer_script.sh** on master host
#### 2 - Run script **slave_installer_script.sh** on slave host

After successful deployment, you can test the cluster. 


