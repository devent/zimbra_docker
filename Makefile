REPOSITORY := erwinnttdata
NAME := zimbra
VERSION ?= 8.7.1_GA_008

build: _build ##@targets Builds the docker image.

rebuild: _rebuild ##@targets Builds the docker image anew.

clean: _clean ##@targets Removes the docker image.

deploy: _deploy ##@targets Deploys the docker image to the repository.

zimbra-bash: check-bind check-zimbra-data
	bind_container_ip=$$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' bind) && \
	docker run -it \
	--dns $$bind_container_ip \
	--hostname "zimbra" \
	-e "ZIMBRA_FQDN=zimbra.local" \
	-p "8022:22" \
	-p "8025:25" \
	-p "8080:80" \
	-p "8110:110" \
	-p "8143:143" \
	-p "8389:389" \
	-p "8443:443" \
	-p "8993:993" \
	-p "7025:7025" \
	--volumes-from "zimbra-data" \
	--name zimbra $(REPOSITORY)/$(NAME) bash

zimbra-bash-no-volumes: check-bind
	bind_container_ip=$$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' bind) && \
	docker run -it \
	--dns $$bind_container_ip \
	--hostname "zimbra" \
	-e "ZIMBRA_FQDN=zimbra.local" \
	-p "8022:22" \
	-p "8025:25" \
	-p "8080:80" \
	-p "8110:110" \
	-p "8143:143" \
	-p "8389:389" \
	-p "8443:443" \
	-p "8993:993" \
	-p "7025:7025" \
	--name zimbra $(REPOSITORY)/$(NAME) bash

zimbra-setup: check-bind check-zimbra-data
	bind_container_ip=$$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' bind) && \
	docker run -it \
	--dns $$bind_container_ip \
	--hostname "zimbra" \
	-e "ZIMBRA_FQDN=zimbra.local" \
	-p "8022:22" \
	-p "8025:25" \
	-p "8080:80" \
	-p "8110:110" \
	-p "8143:143" \
	-p "8389:389" \
	-p "8443:443" \
	-p "8993:993" \
	-p "7025:7025" \
	--volumes-from "zimbra-data" \
	--name zimbra $(REPOSITORY)/$(NAME) libexec/zmsetup.pl

zimbra: check-bind check-zimbra-data
	bind_container_ip=$$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' bind) && \
	docker run -d \
	--dns $$bind_container_ip \
	--hostname "zimbra" \
	-e "ZIMBRA_FQDN=zimbra.local" \
	-p "8022:22" \
	-p "8025:25" \
	-p "8080:80" \
	-p "8110:110" \
	-p "8143:143" \
	-p "8389:389" \
	-p "8443:443" \
	-p "8993:993" \
	-p "7025:7025" \
	--volumes-from "zimbra-data" \
	--name zimbra $(REPOSITORY)/$(NAME)

zimbra-data:
	docker run \
	-v "zimbra:/opt/zimbra" \
	-v "zimbra-etc:/etc" \
	-v "zimbra-var:/var" \
	--name zimbra-data \
	$(REPOSITORY)/$(NAME) \
	bash -c "true"

bind-start:
	docker run -d \
	-p 53:53 \
	-p 53:53/udp \
	-p 10000:10000 \
	-v /appl/bind/etc:/etc/bind \
	-v /appl/bind/zones:/var/lib/bind \
	-v /appl/bind/webmin:/etc/webmin \
	-e PASS=newpass \
	-e NET=172.17.0.0\;192.168.0.0\;10.1.2.0 \
	--name bind \
	--hostname bind \
	cosmicq/docker-bind
	$(MAKE) bind-address

bind-address:
	docker inspect --format '{{ .NetworkSettings.IPAddress }}' bind

check-bind:
	NAME=bind; \
	if ! $(container_running); then \
	echo "Start Bind and configure Zimbra domain."; \
	exit 1; \
	fi

check-zimbra-data:
	NAME="zimbra-data"; \
	if ! $(container_exists); then \
	echo "Start Zimbra data container first."; \
	exit 1; \
	fi

include Makefile.help
include Makefile.functions
include Makefile.image

.PHONY +: build rebuild clean deploy bind-start check-bind check-zimbra-data
