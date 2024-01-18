
vm=vsh-bangunsoft
app=${vm}:latest

build:
	docker build --progress=plain -f Dockerfile -t ${app} .

up: build
	if [ -z `docker network ls -qf name=cloudflared_bangunsoft` ]; then \
		docker network create -d bridge cloudflared_bangunsoft; \
	fi
	docker-compose up -d ${vm} && docker-compose logs -f

down:
	docker-compose down --remove-orphans

bash:
	docker exec -it ${vm} bash

logs:
	docker logs ${vm} -f