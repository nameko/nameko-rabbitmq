ARG TAG=latest

FROM rabbitmq:${TAG}

#########

# copy config file
COPY rabbitmq.config /etc/rabbitmq/rabbitmq.config

# copy ssl keys and certs
COPY ssl /srv/ssl

# overwrite entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
