#!/usr/bin/env bash

KAFKA_HEAP_OPTS=${JVMFLAGS:-"-Xmx1G -Xms1G"}
KAFKA_ADVERTISE_PORT=${KAFKA_ADVERTISE_PORT:-"9092"}
KAFKA_DELETE_TOPICS=${KAFKA_DELETE_TOPICS:-"false"}
KAFKA_LISTENER=${KAFKA_LISTENER:-"PLAINTEXT://0.0.0.0:"${KAFKA_ADVERTISE_PORT}}
KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-${SERVICE_HOME}"/logs"}
KAFKA_LOG_RETENTION_HOURS=${KAFKA_LOG_RETENTION_HOURS:-"168"}
KAFKA_NUM_PARTITIONS=${KAFKA_NUM_PARTITIONS:-"1"}
KAFKA_ZK_HOST=${KAFKA_ZK_HOST:-"127.0.0.1"}
KAFKA_ZK_PORT=${KAFKA_ZK_PORT:-"2181"}
KAFKA_EXT_IP=${KAFKA_EXT_IP:-""}

if [ "$KAFKA_EXT_IP" == "" ]; then
 	KAFKA_ADVERTISE_LISTENER=${KAFKA_ADVERTISE_LISTENER:-${KAFKA_LISTENER}}
else
	KAFKA_ADVERTISE_LISTENER=${KAFKA_ADVERTISE_LISTENER:-"PLAINTEXT://"${KAFKA_EXT_IP}":"${KAFKA_ADVERTISE_PORT}}
fi

cat << EOF > ${SERVICE_CONF}
#
#
# Copyright 2015 StreamSets Inc.
#
# Licensed under the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
#
# The base URL of the datacollector, used to create email alert messages.
# If not set http://<hostname>:<http.port> is used
# <hostname> is either taken from http.bindHost or resolved using
# 'hostname -f' if not configured.
#sdc.base.http.url=http://<hostname>:<port>

# HTTP configuration

# Hostname or IP address that data collector will bind to.
# Default is 0.0.0.0 that will bind to all interfaces.
#http.bindHost=0.0.0.0

# Maximum number of HTTP servicing threads.
#http.maxThreads=200

# The port the data collector runs the SDC HTTP endpoint.
# If different that -1, the SDC will run on this port
# If 0, the SDC will pick up a random port
# If the https.port is different that -1 or 0 and http.port is different than -1 or 0, the HTTP endpoint
# will redirect to the HTTPS endpoint.
http.port=18630

# HTTPS configuration

# The port the data collector runs the SDC HTTPS endpoint.
# If different that -1, the SDC will run over SSL on this port
# If 0, the SDC will pick up a random port
https.port=-1

# Reverse Proxy / Load Balancer configuration

# SDC will handle X-Forwarded-For, X-Forwarded-Proto, X-Forwarded-Port
# headers issued by a reverse proxy such as HAProxy, ELB, nginx when set to true.
# Set to true when hosting SDC behind a reverse proxy / load balancer.
http.enable.forwarded.requests=false

# Java keystore file, in the SDC 'etc/' configuration directory
https.keystore.path=keystore.jks

# Password for the keystore file,
# By default, the password is loaded from the 'keystore-password.txt'
# from the SDC 'etc/' configuration directory
https.keystore.password=${file("keystore-password.txt")}

# Path to keystore file on worker node. This should always be an absolute location
https.cluster.keystore.path=/opt/security/jks/sdc-keystore.jks

# Password for keystore file on worker
https.cluster.keystore.password=${file("/opt/security/jks/keystore-password.txt")}

# Truststore configs
# By default, if below configs are commented then cacerts from JRE lib directory will be used as truststore

# Java truststore file on gateway sdc which stores certificates to trust identity of workers
#https.truststore.path=

# Password for truststore file
#https.truststore.password=

# Path to truststore file on worker node. This should always be an absolute location
#https.cluster.truststore.path=/opt/security/jks/sdc-truststore.jks

# Password for truststore file on worker
#https.cluster.truststore.password=${file("/opt/security/jks/truststore-password.txt")}

# HTTP Session Timeout
# Max period of inactivity, after which the HTTP session is invalidated, in seconds.
# Default value is 86400 seconds (24 hours)
# value -1 means no timeout
http.session.max.inactive.interval=86400

# The authentication for the HTTP endpoint of the data collector
# Valid values are: 'none', 'basic', 'digest', or 'form'
#
http.authentication=form

# Authentication Login Module
# Valid values are: 'file' and 'ldap'
# For 'file', the authentication and role information is read from a property file (etc/basic-realm.properties,
#   etc/digest-realm.properties or etc/form-realm.properties based on the 'http.authentication' value).
# For 'ldap', the authentication and role information is read from a LDAP Server
#   and LDAP connection information is read from etc/ldap-login.conf.
http.authentication.login.module=file

# The realm used for authentication
# A file with the realm name and '.properties' extension must exist in the data collector configuration directory
# If this property is not set, the realm name is '<http.authentication>-realm'
#http.digest.realm=local-realm

# Check the permissions of the realm file should be owner only
http.realm.file.permission.check=true

# LDAP group to Data Collector role mapping
# the mapping is specified as the following pattern:
#    <ldap-group>:<sdc-role>(,<sdc-role>)*(;<ldap-group>:<sdc-role>(,<sdc-role>)*)*
# e.g.
#    Administrator:admin;Manager:manager;DevOP:creator;Tester:guest;
http.authentication.ldap.role.mapping=

# LDAP login module name as present in the JAAS config file.
# If no value is specified, the login module name is assumed to be "ldap"
ldap.login.module.name=

# HTTP access control (CORS)
http.access.control.allow.origin=*
http.access.control.allow.headers=origin, content-type, accept, authorization, x-requested-by, x-ss-user-auth-token, x-ss-rest-call
http.access.control.allow.methods=GET, POST, PUT, DELETE, OPTIONS, HEAD

# Runs the data collector within a Kerberos session which is propagated to all stages.
# This is useful for stages that require Kerberos authentication with the services they interact with
kerberos.client.enabled=false

# The kerberos principal to use for the Kerberos session.
# It should be a service principal. If the hostname part of the service principal is '_HOST' or '0.0.0.0',
# the hostname will be replaced with the actual complete hostname of the data collector as advertised by the
# unix command 'hostname -f'
kerberos.client.principal=sdc/_HOST@EXAMPLE.COM

# The location of the keytab file for the specified principal. If the path is relative, the keytab file will be
# looked under the data collector configuration directory
kerberos.client.keytab=sdc.keytab

preview.maxBatchSize=10
preview.maxBatches=10

production.maxBatchSize=1000

#This option determines the number of error records, per stage, that will be retained in memory when the pipeline is
#running. If set to zero, error records will not be retained in memory.
#If the specified limit is reached the oldest records will be discarded to make room for the newest one.
production.maxErrorRecordsPerStage=100

#This option determines the number of pipeline errors that will be retained in memory when the pipeline is
#running. If set to zero, pipeline errors will not be retained in memory.
#If the specified limit is reached the oldest error will be discarded to make room for the newest one.
production.maxPipelineErrors=100

# Max number of concurrent REST calls allowed for the /rest/v1/admin/log endpoint
max.logtail.concurrent.requests=5

# Max number of concurrent WebSocket calls allowed
max.webSockets.concurrent.requests=15

# Monitor memory of stages. Use only to test real-world load usage in test or production environments.
monitor.memory=false

# Customize header title for SDC UI
ui.header.title=

ui.local.help.base.url=/docs
ui.hosted.help.base.url=https://www.streamsets.com/documentation/datacollector/2.3.0.1/userguide/help

ui.refresh.interval.ms=2000
ui.jvmMetrics.refresh.interval.ms=4000

# SDC sends anonymous usage information using Google Analytics to StreamSets.
ui.enable.usage.data.collection=true

# If true SDC UI will use WebSocket to fetch pipeline status/metrics/alerts otherwise UI will poll every few seconds
# to get the Pipeline status/metrics/alerts.
ui.enable.webSocket=true

# Number of changes supported by undo/redo functionality.
# UI archives Pipeline Configuration/Rules in browser memory to support undo/redo functionality.
ui.undo.limit=10

# SMTP configuration to send alert emails
# All properties starting with 'mail.' are used to create the JavaMail session, supported protocols are 'smtp' & 'smtps'
mail.transport.protocol=smtp
mail.smtp.host=localhost
mail.smtp.port=25
mail.smtp.auth=false
mail.smtp.starttls.enable=false
mail.smtps.host=localhost
mail.smtps.port=465
mail.smtps.auth=false
# If 'mail.smtp.auth' or 'mail.smtps.auth' are to true, these properties are used for the user/password credentials,
# ${file("email-password.txt")} will load the value from the 'email-password.txt' file in the config directory (where this file is)
xmail.username=foo
xmail.password=${file("email-password.txt")}
# FROM email address to use for the messages
xmail.from.address=sdc@$localhost

#Indicates the location where runtime configuration properties can be found.
#Value 'embedded' implies that the runtime configuration properties are present in this file and are prefixed with
#'runtime.conf_'.
#A value other than 'embedded' is treated as the name of a properties file from which the runtime configuration
#properties must be picked up. Note that the properties should not be prefixed with 'runtime.conf_' in this case.
runtime.conf.location=embedded

#Observer related

#The size of the queueName where the pipeline queues up data rule evaluation requests.
#Each request is for a stream and contains sampled records for all rules that apply to that lane.
observer.queue.size=100

#Sampled records which pass evaluation are cached for user to view. This determines the size of the cache and there is
#once cache per data rule
observer.sampled.records.cache.size=100

#The time to wait before dropping a data rule evaluation request if the observer queueName is full.
observer.queue.offer.max.wait.time.ms=1000


#Maximum number of private classloaders to allow in the data collector.
#Stage that have configuration singletons (i.e. Hadoop FS & Hbase) require private classloaders
max.stage.private.classloaders=50

# Pre-multiplier size of the thread pool.
# Default value is sufficient to run 22 pipelines.
# One pipeline requires 5 Threads and pipelines share threads using thread pool.
# Approximate runner thread pool size = (Number of Running Pipelines) * 2.2
# Increasing this value will not increase parallelisation of individual pipelines.
runner.thread.pool.size=50

# Library aliases mapping to keep backward compatibility on pipelines when library names change
# The current aliasing mapping is to handle 1.0.0beta2 to 1.0.0 library names changes
#
# IMPORTANT: Under normal circumstances all these properties should not be changed
#
library.alias.streamsets-datacollector-apache-kafka_0_8_1_1-lib=streamsets-datacollector-apache-kafka_0_8_1-lib
library.alias.streamsets-datacollector-apache-kafka_0_8_2_0-lib=streamsets-datacollector-apache-kafka_0_8_2-lib
library.alias.streamsets-datacollector-apache-kafka_0_8_2_1-lib=streamsets-datacollector-apache-kafka_0_8_2-lib
library.alias.streamsets-datacollector-cassandra_2_1_5-lib=streamsets-datacollector-cassandra_2-lib
library.alias.streamsets-datacollector-cdh5_2_1-lib=streamsets-datacollector-cdh_5_2-lib
library.alias.streamsets-datacollector-cdh5_2_3-lib=streamsets-datacollector-cdh_5_2-lib
library.alias.streamsets-datacollector-cdh5_2_4-lib=streamsets-datacollector-cdh_5_2-lib
library.alias.streamsets-datacollector-cdh5_3_0-lib=streamsets-datacollector-cdh_5_3-lib
library.alias.streamsets-datacollector-cdh5_3_1-lib=streamsets-datacollector-cdh_5_3-lib
library.alias.streamsets-datacollector-cdh5_3_2-lib=streamsets-datacollector-cdh_5_3-lib
library.alias.streamsets-datacollector-cdh5_4_0-cluster-cdh_kafka_1_2_0-lib=streamsets-datacollector-cdh_5_4-cluster-cdh_kafka_1_2-lib
library.alias.streamsets-datacollector-cdh5_4_0-lib=streamsets-datacollector-cdh_5_4-lib
library.alias.streamsets-datacollector-cdh5_4_1-cluster-cdh_kafka_1_2_0-lib=streamsets-datacollector-cdh_5_4-cluster-cdh_kafka_1_2-lib
library.alias.streamsets-datacollector-cdh5_4_1-lib=streamsets-datacollector-cdh_5_4-lib
library.alias.streamsets-datacollector-cdh_5_4-cluster-cdh_kafka_1_2_0-lib=streamsets-datacollector-cdh_5_4-cluster-cdh_kafka_1_2-lib
library.alias.streamsets-datacollector-cdh_kafka_1_2_0-lib=streamsets-datacollector-cdh_kafka_1_2-lib
library.alias.streamsets-datacollector-elasticsearch_1_4_4-lib=streamsets-datacollector-elasticsearch_1_4-lib
library.alias.streamsets-datacollector-elasticsearch_1_5_0-lib=streamsets-datacollector-elasticsearch_1_5-lib
library.alias.streamsets-datacollector-hdp_2_2_0-lib=streamsets-datacollector-hdp_2_2-lib
library.alias.streamsets-datacollector-jython_2_7_0-lib=streamsets-datacollector-jython_2_7-lib
library.alias.streamsets-datacollector-mongodb_3_0_2-lib=streamsets-datacollector-mongodb_3-lib
library.alias.streamsets-datacollector-cassandra_2-lib=streamsets-datacollector-cassandra_3-lib

# Stage aliases for mapping to keep backward compatibility on pipelines when stages move libraries
# The current alias mapping is to handle moving the jdbc stages to their own library
#
# IMPORTANT: Under normal circumstances all these properties should not be changed
#
stage.alias.streamsets-datacollector-basic-lib,com_streamsets_pipeline_stage_destination_jdbc_JdbcDTarget=streamsets-datacollector-jdbc-lib,com_streamsets_pipeline_stage_destination_jdbc_JdbcDTarget
stage.alias.streamsets-datacollector-basic-lib,com_streamsets_pipeline_stage_origin_jdbc_JdbcDSource=streamsets-datacollector-jdbc-lib,com_streamsets_pipeline_stage_origin_jdbc_JdbcDSource
stage.alias.streamsets-datacollector-basic-lib,com_streamsets_pipeline_stage_origin_omniture_OmnitureDSource=streamsets-datacollector-omniture-lib,com_streamsets_pipeline_stage_origin_omniture_OmnitureDSource
stage.alias.streamsets-datacollector-cdh_5_7-cluster-cdh_kafka_2_0-lib,com_streamsets_pipeline_stage_destination_kafka_KafkaDTarget=streamsets-datacollector-cdh_kafka_2_0-lib,com_streamsets_pipeline_stage_destination_kafka_KafkaDTarget
stage.alias.streamsets-datacollector-elasticsearch_1_4-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_1_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_1_6-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_1_7-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_2_0-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_2_1-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_2_2-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_2_3-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_2_4-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_5_0-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_1_4-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_1_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_1_6-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_1_7-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_2_0-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_2_1-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_2_2-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_2_3-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_2_4-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget
stage.alias.streamsets-datacollector-elasticsearch_5_0-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget=streamsets-datacollector-elasticsearch_5-lib,com_streamsets_pipeline_stage_destination_elasticsearch_ToErrorElasticSearchDTarget

# System and user stage libraries whitelists and blacklists
#
# If commented out all stagelibraries directories are used.
#
# Given 'system' or 'user', only whitelist or blacklist can be set, if both are set the Data Collector will fail to start
#
# Specify stage library directories separated by commas
#
# The MapR and Apache Solr 6 stage libraries are blacklisted by default.
# Apache Solr 6, Google Bigtable and Elasticsearch 5 stage libraries are blacklisted
# because they require the minimum version of Java 8
# To use one of the stage libraries, remove the library that you want to use from
# the system.statelibs.blacklist property
#
#system.stagelibs.whitelist=
system.stagelibs.blacklist=\
  streamsets-datacollector-mapr_5_0-lib,\
  streamsets-datacollector-mapr_5_1-lib,\
  streamsets-datacollector-mapr_5_2-lib
#
#user.stagelibs.whitelist=
#user.stagelibs.blacklist=

#
# Additional Configuration files to include in to the configuration.
# Value of this property is the name of the configuration file separated by commas.
#
config.includes=dpm.properties,vault.properties


#
# Record Sampling configurations indicate the size of the subset (sample set) that must be chosen from a population (of records).
# Default configuration values indicate the sampler to select 1 out of 10000 records
#
# For better performance simplify the fraction ( sdc.record.sampling.sample.size / sdc.record.sampling.population.size )
# i.e., specify ( 1 / 40 ) instead of ( 250 / 10000 ).
sdc.record.sampling.sample.size=1
sdc.record.sampling.population.size=10000

#
# Pipeline State are cached for faster access.
# Specifies the maximum number of pipeline state entries the cache may contain.
store.pipeline.state.cache.maximum.size=100

# Specifies that each pipeline state entry should be automatically removed from the cache once a fixed duration
# has elapsed after the entry's creation, the most recent replacement of its value, or its last access.
# In minutes
store.pipeline.state.cache.expire.after.access=10
EOF

