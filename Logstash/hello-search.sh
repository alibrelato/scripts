java -jar logstash-1.1.13-flatjar.jar agent -f hello-search.conf
curl http://localhost:9200/_search?pretty=1&q=*
