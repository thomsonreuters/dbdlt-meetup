docker-compose -f ./docker-compose.authority.yml \
  -f ./docker-compose.entity1.yml \
  -f ./docker-compose.entity2.yml \
  down

docker rm $(docker ps -aq --filter='name=dev' | paste -sd " " -)
docker rmi -f $(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'dev-')