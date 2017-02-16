#
#
# Licensed to the Apache Software Foundation (ASF) under one
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

FROM rawmind/alpine-jvm8:1.8.102-2
MAINTAINER Jeff Kolb <jeffkolb@gmail.com>

# Set environment
ENV SERVICE_HOME=/opt/streamsets-datacollector \
    SERVICE_NAME=streamsets \
    SERVICE_VERSION=2.3.0.1 \
    SERVICE_USER=sdc \
    SERVICE_UID=10003 \
    SERVICE_GROUP=sdc \
    SERVICE_GID=10003 \
    SERVICE_VOLUME=/opt/tools \
    SERVICE_URL=https://archives.streamsets.com/datacollector

ENV SERVICE_RELEASE=2.3.0.1 \
    SERVICE_CONF=${SERVICE_HOME}/config/sdc.properties 
	
# Install linux applications
RUN apk --no-cache add bash curl

# Install and configure streamsets
RUN cd /tmp \
	&& curl -O -L "${SERVICE_URL}/${SERVICE_VERSION}/tarball/streamsets-datacollector-core-${SERVICE_RELEASE}.tgz" \
	&& tar xzf "/tmp/streamsets-datacollector-core-${SERVICE_RELEASE}.tgz" -C /opt/ \
	&& rm -rf "/tmp/streamsets-datacollector-core-${SERVICE_RELEASE}.tgz" \
	&& mv "${SERVICE_HOME}-${SERVICE_RELEASE}" ${SERVICE_HOME} \
	&& addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} \
	&& adduser -g "${SERVICE_NAME} user" -D -h ${SERVICE_HOME} -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER} 

# Add all files
ADD root /
RUN chmod +x ${SERVICE_HOME}/bin/*.sh \
  && chown -R ${SERVICE_USER}:${SERVICE_GROUP} ${SERVICE_HOME} /opt/monit


USER $SERVICE_USER
WORKDIR $SERVICE_HOME

EXPOSE 18630
