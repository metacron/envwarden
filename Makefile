all:

.PHONY:

docker_image: Dockerfile
	docker build -t envwarden:latest --network host .