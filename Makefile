# docker image version
VERSION := 9.9.5-20170129
# docker image name
IMAGE_NAME := sameersbn/bind
# docker container name
NAME := bind-webmin
# docker container arguments.
VOLUMES := -v /var/bind:/data
PORTS := -p 53:53/tcp -p 53:53/udp -p 10000:10000/tcp

include docker_make_utils/Makefile.help
include docker_make_utils/Makefile.functions
include docker_make_utils/Makefile.container

define DOCKER_CMD :=
docker run \
--name $(NAME) \
$(VOLUMES) \
$(PORTS) \
-d \
$(IMAGE)
endef

run: _run ##@default Starts the container.
.PHONY: run

rerun: _rerun ##@targets Stops and starts the container.
.PHONY: rerun

rm: _rm ##@targets Stops and removes the container.
.PHONY: rm

clean: _clean ##@targets Stops and removes the container and removes all created files.
.PHONY: clean

test: _test ##@targets Tests if the container is running.
.PHONY: test

restart: _restart ##@targets Restarts the container.
.PHONY: restart
