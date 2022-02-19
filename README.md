# diploma
## Environment variables and config
For composer-update use .env  
For kubernetes (minikube) use .env.kuber  
Example .env in env.example  

## Build docker image (dev)
docker build -t "nhlstats:<version>" -t "nhlstats:latest" -f docker/Dockerfile.app .

## Run app in kubernetes (minikube, dev)
/bin/bash run_in_kuber

## Remove app from kubernetes (minikube, dev)
/bin/bash remove_from_kuber
