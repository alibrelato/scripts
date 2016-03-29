java -jar logstash-1.1.13-flatjar.jar agent -f logstash-squid.conf -- web --backend elasticsearch://localhost/ &

