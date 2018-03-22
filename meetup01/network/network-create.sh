docker-compose -f ./docker-compose.authority.yml \
  -f ./docker-compose.entity1.yml \
  -f ./docker-compose.entity2.yml \
  up -d

  sleep 20

  ./make-channels.sh
  ./deploy-chaincode.sh