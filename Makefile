RABBITMQ_VERSION ?= 3.6.6

minor_version = $(word 2, $(subst ., ,$(RABBITMQ_VERSION)))
build_version = $(word 3, $(subst ., ,$(RABBITMQ_VERSION)))

new_gpg_key = "0A9AF2115F4687BD29803A206B73A36E6026DFCA"
old_gpg_key = "F78372A06FF50C80464FC1B4F7B8CEA6056E8E56"

ifeq ($(shell test $(minor_version) -lt 6; echo $$?),0)
	TAR_EXT="gz"
	GPG_KEY=$(old_gpg_key)
else
	TAR_EXT="xz"
	ifeq ($(shell test $(build_version) -lt 3; echo $$?),0)
		GPG_KEY=$(old_gpg_key)
	else
		GPG_KEY=$(new_gpg_key)
	endif
endif

build:
	docker build -t nameko/nameko-rabbitmq:$(RABBITMQ_VERSION) -f Dockerfile --build-arg RABBITMQ_VERSION=$(RABBITMQ_VERSION) --build-arg GPG_KEY=$(GPG_KEY) --build-arg TAR_EXT=$(TAR_EXT) .;

login:
	@docker login -u "$(DOCKER_USER)" -p "$(DOCKER_PASS)"

ifeq ($(shell git rev-parse --abbrev-ref HEAD), master)
push: login
	docker push nameko/nameko-rabbitmq:$(RABBITMQ_VERSION)
else
push:
	@echo "skipping push, not master branch"
endif

run:
	docker run -it --rm -v nameko-rabbitmq-certs:/mnt/certs -p 15672:15672 -p 5672:5672 -p 5671:5671 --name nameko-rabbitmq nameko/nameko-rabbitmq:$(RABBITMQ_VERSION)

