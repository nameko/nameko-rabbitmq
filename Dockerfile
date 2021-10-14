ARG TAG=latest

FROM rabbitmq:${TAG}

#########

# copy config file
COPY rabbitmq.config /etc/rabbitmq/rabbitmq.config

# copy ssl keys and certs
COPY ssl /srv/ssl

# enable rabbitmq_auth_mechanism_ssl plugin
RUN rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl