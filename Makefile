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

run: clean
	docker run -d --rm -p 15672:15672 -p 5672:5672 -p 5671:5671 --name nameko-rabbitmq nameko/nameko-rabbitmq:$(RABBITMQ_VERSION)
	docker cp nameko-rabbitmq:/srv/ssl certs
	@printf "Waiting for container to be ready"
	@booting=1; \
	while [ $${booting} -ne 0 ] ; do \
		curl -s http://localhost:15672/api/overview > /dev/null; \
		booting=$$?; \
		sleep 2; \
		printf "."; \
	done; \
	printf "\n"

clean:
	docker stop nameko-rabbitmq || true
	rm -r certs || true

test: run
	py.test test.py
