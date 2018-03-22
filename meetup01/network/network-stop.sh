docker-compose -f ./docker-compose.authority.yml \
  -f ./docker-compose.entity1.yml \
  -f ./docker-compose.entity2.yml \
  stop

docker stop $(docker ps -aq --filter='name=dev' | paste -sd " " -)