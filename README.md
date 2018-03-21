# amq-ha-shared-store-demo
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

