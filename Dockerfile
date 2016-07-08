FROM quay.io/pires/docker-elasticsearch:2.3.3

MAINTAINER pjpires@gmail.com

# Override elasticsearch.yml config, otherwise plug-in install will fail
ADD do_not_use.yml /elasticsearch/config/elasticsearch.yml

# Install Elasticsearch plug-ins
RUN /elasticsearch/bin/plugin install io.fabric8/elasticsearch-cloud-kubernetes/2.3.3 --verbose

# Install SearchGuard plugin
RUN /elasticsearch/bin/plugin install -b com.floragunn/search-guard-ssl/2.3.3.13

# Add the keystore and truststore for SG SSL
ENV CERTS_PATH="/elasticsearch/config/certs"
RUN mkdir $CERTS_PATH

# TODO: obtain from K8S Secrets
ADD node-0-keystore.jks truststore.jks $CERTS_PATH/

# Append SG SSL config to the config file
# https://github.com/floragunncom/search-guard-ssl-docs/blob/master/quickstart.md

RUN echo $'\n\nsearchguard.ssl.transport.keystore_filepath: certs/node-0-keystore.jks\n\
searchguard.ssl.transport.keystore_password: changeit\n\
searchguard.ssl.transport.truststore_filepath: certs/truststore.jks\n\
searchguard.ssl.transport.truststore_password: changeit\n\
searchguard.ssl.transport.enforce_hostname_verification: false\n\
\n\
searchguard.ssl.http.enabled: true\n\
searchguard.ssl.http.keystore_filepath: certs/node-0-keystore.jks\n\
searchguard.ssl.http.keystore_password: changeit\n\
searchguard.ssl.http.truststore_filepath: certs/truststore.jks\n\
searchguard.ssl.http.truststore_password: changeit' \
  >> $CONFIG_PATH

# Override elasticsearch.yml config, otherwise plug-in install will fail
ADD elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# Copy run script
COPY run.sh /
