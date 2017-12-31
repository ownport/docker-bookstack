build-docker-image:
	docker build -t ownport/bookstack:0.19.0 .

run-bookstack-container:
	docker run --rm --name bookstack \
		-v $(shell pwd):/data \
		ownport/bookstack:0.19.0

run-bookstack-container-cli:
	docker run -ti --rm --name bookstack \
		-v $(shell pwd):/data \
		ownport/bookstack:0.19.0 \
		/bin/sh

stop-bookstack-container:
	docker stop bookstack
