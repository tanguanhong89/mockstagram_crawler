sudo docker run -d --rm -p 9091:9091 --name mockstagram_pushgateway prom/pushgateway --web.enable-admin-api && sudo docker run -d --rm --network=host -p 9090:9090 -v /home/gh/Desktop/experimental/profiler/infraSetup/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml -v /home/gh/Desktop/experimental/profiler/infraSetup/prometheus/targets.json:/etc/prometheus/targets.json -v /home/gh/profiler_store/prometheus:/prometheus --name mockstagram_prometheus quay.io/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --storage.tsdb.retention.time=2h --web.console.libraries=/usr/share/prometheus/console_libraries --web.console.templates=/usr/share/prometheus/consoles --web.enable-lifecycle --web.enable-admin-api --storage.tsdb.min-block-duration=1h --storage.tsdb.max-block-duration=1h && sudo docker run -d --rm --network=host -v /home/gh/profiler_store/prometheus:/var/prometheus -v /home/gh/profiler_store/objstore:/objstore -v /home/gh/Desktop/experimental/profiler/infraSetup/thanos/store.yml:/store.yml --name mockstagram_thanos_sidecar docker.io/thanosio/thanos:master-2019-12-23-39f8623b sidecar --prometheus.url http://localhost:9090  --http-address 0.0.0.0:19191 --grpc-address 0.0.0.0:19090 --objstore.config-file  "/store.yml" --tsdb.path /var/prometheus && sudo docker run -d --rm --network=host -v /home/gh/profiler_store/objstore:/objstore -v /home/gh/Desktop/experimental/profiler/infraSetup/thanos/store.yml:/store.yml --name mockstagram_thanos_store  docker.io/thanosio/thanos:master-2019-12-23-39f8623b store --grpc-address 0.0.0.0:19091 --objstore.config-file "/store.yml" && sudo docker run -d --rm --network=host --name mockstagram_thanos_querier docker.io/thanosio/thanos:master-2019-12-23-39f8623b query --http-address 0.0.0.0:19192 --store 0.0.0.0:19090 --store 0.0.0.0:19091 && sudo docker run -d -p 27018:27017 --rm -v /home/gh/profiler_store/mongo:/data/db --name mockstagram_mongodb  mongo:3.6 && sudo docker run -d --rm --network=host -v /home/gh/Desktop/experimental/profiler/infraSetup/_tmp.sh:/usr/_tmp.sh --entrypoint /bin/sh --name mockstagram_pushwiper  byrnedo/alpine-curl:0.1.8 /usr/_tmp.sh