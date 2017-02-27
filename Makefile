include Makefile.help
include Makefile.functions

REPOSITORY := erwinnttdata
NAME := zimbra
VERSION ?= 8.7.1_GA_003
PROXY := -e "https_proxy=$$HTTPS_PROXY" -e "http_proxy=$$HTTP_PROXY" \
-e "HTTPS_PROXY=$$HTTPS_PROXY" -e "HTTP_PROXY=$$HTTP_PROXY" \
-e "ftp_proxy=$$FTP_PROXY" -e "FTP_PROXY=$$FTP_PROXY" \
-e "no_proxy=$$NO_PROXY" -e "NO_PROXY=$$NO_PROXY"


bind-start:
	docker run -d \
	-p 53:53 \
	-p 53:53/udp \
	-p 10000:10000 \
	-v /var/lib/bind/etc:/etc/bind \
	-v /var/lib/bind/zones:/var/lib/bind \
	-v /var/lib/bind/webmin:/etc/webmin \
	-e PASS=newpass \
	-e NET=172.17.0.0\;192.168.0.0\;10.1.2.0 \
	--name bind \
	--hostname bind \
	cosmicq/docker-bind
	$(MAKE) bind-address

bind-address:
	docker inspect --format '{{ .NetworkSettings.IPAddress }}' bind

.PHONY +: build rebuild clean deploy bind-start check-bind check-zimbra-data
