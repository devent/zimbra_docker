REPOSITORY := erwinnttdata
NAME := zimbra
VERSION ?= 8.7.1_GA_003
PROXY := -e "https_proxy=$$HTTPS_PROXY" -e "http_proxy=$$HTTP_PROXY" \
-e "HTTPS_PROXY=$$HTTPS_PROXY" -e "HTTP_PROXY=$$HTTP_PROXY" \
-e "ftp_proxy=$$FTP_PROXY" -e "FTP_PROXY=$$FTP_PROXY" \
-e "no_proxy=$$NO_PROXY" -e "NO_PROXY=$$NO_PROXY"


build: _build ##@targets Builds the docker image.

rebuild: _rebuild ##@targets Builds the docker image anew.

clean: _clean ##@targets Removes the docker image.

deploy: _deploy ##@targets Deploys the docker image to the repository.

cleanup:
	docker rm -f zimbra zimbra-data; true
	sudo rm -rf "/appl/zimbra"

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
	--name zimbra $(REPOSITORY)/$(NAME):$(VERSION) bash

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
	--name zimbra $(REPOSITORY)/$(NAME):$(VERSION) bash

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
	--name zimbra \
	$(REPOSITORY)/$(NAME):$(VERSION)

zimbra-data:
	set -x && \
	bind_container_ip=$$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' bind) && \
	docker run \
	-it \
	--dns $$bind_container_ip \
	--hostname "zimbra" \
	$(PROXY) \
	-e "ZIMBRA_FQDN=zimbra.local" \
	-u root \
	-v "/appl/zimbra/data:/opt/zimbra/data" \
	-v "/appl/zimbra/db:/opt/zimbra/db" \
	-v "/appl/zimbra/index:/opt/zimbra/index" \
	-v "/appl/zimbra/mariadb:/opt/zimbra/mariadb" \
	-v "/appl/zimbra/store:/opt/zimbra/store" \
	-v "/appl/zimbra/zmstat:/opt/zimbra/zmstat" \
	-v "/appl/zimbra/opt/etc:/opt/etc" \
	-v "/appl/zimbra/opt/var:/opt/var" \
	--name "zimbra-data" $(REPOSITORY)/$(NAME):$(VERSION) bash

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
