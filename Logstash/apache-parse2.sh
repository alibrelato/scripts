java -jar logstash-1.1.13-flatjar.jar agent -f apache-parse.conf
nc localhost 3333 < apache_log.1
