helm upgrade --install -n 'sumologic-demo'  --create-namespace  -f values.yaml  release-1 sumologic/sumologic --set sumologic.accessId=$SUMO_ACCESS_ID --set sumologic.accessKey=$SUMO_ACCESS_KEY