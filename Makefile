include Makefile.inc
DATE:=$(shell date)
DOCKER=$(shell which docker)

default_target: run enter

define sed
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"$(1)"?"$(2)"?g
endef
define sed0
	@find ${MANIFEST} -type f -name "Dockerfile" | xargs sed -i s?"$(1)"?"$(2)"?g
endef

restart: rm mk mv docker
docker: build run
all: build push deploy


build:
	@docker $@ -t ${IMAGE} -f Dockerfile .

push:
	@docker $@ ${IMAGE}

pull:
	@docker $@ ${IMAGE}

run: ln
	${DOCKER} $@ -d -v $(shell pwd)/src:/workspace -v $(shell pwd)/data:/data --name ${NAME} --restart=on-failure:5 ${IMAGE} tail -f /dev/null

clean: stop rm
rm: 
	-${DOCKER} $@ ${NAME}

stop:
	-${DOCKER} $@ ${NAME}

enter: exec

exec:
	docker $@ -it ${NAME} /bin/bash

ln:
	[[ -d $(shell pwd)/data ]] || $@ -sf $(PROJECT)/data $(shell pwd)/data
	[[ -d $(shell pwd)/src ]] || $@ -sf $(PROJECT)/src $(shell pwd)/src


.PHONY: build push restart docker all rm run clean stop enter test pull ln
