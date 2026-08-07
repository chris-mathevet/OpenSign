.PHONY: build-server-image build-client-image build-all-images install uninstall true-uninstall all

SERVER_IMAGE_NAME = inlibro-opensign-server:latest
CLIENT_IMAGE_NAME = inlibro-opensign:latest

build-server-image:
	docker rmi $(SERVER_IMAGE_NAME) 2>/dev/null || true
	docker build -t $(SERVER_IMAGE_NAME) -f ./apps/OpenSignServer/Dockerhubfile . --no-cache

build-client-image:
	docker rmi $(CLIENT_IMAGE_NAME) 2>/dev/null || true
	docker build -t $(CLIENT_IMAGE_NAME) -f ./apps/OpenSign/Dockerhubfile . --no-cache

build-all-images: build-server-image build-client-image

install:
	./installation-opensign.sh  \
		--host-url=$(host_url) \
		--smtp-host=$(smtp_host) \
		--smtp-port=$(smtp_port)

uninstall:
	./installation-opensign.sh --uninstall

true-uninstall:
	./installation-opensign.sh --true-uninstall

all: build-all-images install