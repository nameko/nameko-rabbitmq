RABBITMQ_VERSION ?= 3.6.6
ALPINE ?= -alpine

minor_version = $(word 2, $(subst ., ,$(RABBITMQ_VERSION)))
build_version = $(word 3, $(subst ., ,$(RABBITMQ_VERSION)))

ifeq ($(shell test $(minor_version) -lt 6; echo $$?),0)
	ALPINE=
else
	ifeq ($(shell test $(build_version) -lt 6; echo $$?),0)
		ALPINE=
	endif
endif

certs:
	cd certgen; ./generate.sh
	cp certgen/testca/cacert.pem ssl/cacert.pem
	cp certgen/testca/private/cakey.pem ssl/cakey.pem
	cp certgen/server/cert.pem ssl/servercert.pem
	cp certgen/server/key.pem ssl/serverkey.pem
	cp certgen/client/cert.pem ssl/clientcert.pem
	cp certgen/client/key.pem ssl/clientkey.pem
	cd certgen; ./clean.sh

build:
	docker build -t nameko/nameko-rabbitmq:$(RABBITMQ_VERSION) -f Dockerfile --build-arg TAG=$(RABBITMQ_VERSION)-management$(ALPINE) .;

login:
	@docker login -u "$(DOCKER_USER)" -p "$(DOCKER_PASS)"

ifeq ($(TRAVIS_BRANCH), master)
push: login
	docker push nameko/nameko-rabbitmq:$(RABBITMQ_VERSION)
else
push:
	@echo "skipping push, not master branch"
endif

run:
	docker run -it --rm -v nameko-rabbitmq-certs:/mnt/certs -p 15672:15672 -p 5672:5672 -p 5671:5671 --name nameko-rabbitmq nameko/nameko-rabbitmq:$(RABBITMQ_VERSION)

