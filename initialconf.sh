#Ips Red front-api
apiIp=$(sudo docker inspect -f '{{ index .NetworkSettings.Networks "front-api" "IPAddress" }}' api)
frontIp=$(sudo docker inspect -f '{{ index .NetworkSettings.Networks "front-api" "IPAddress" }}' frontend)

#Ips Red front-db
dbIp=$(sudo docker inspect -f '{{ index .NetworkSettings.Networks "front-db" "IPAddress" }}' db)
frontIp2=$(sudo docker inspect -f '{{ index .NetworkSettings.Networks "front-db" "IPAddress" }}' frontend)

#Id contenedores
pidApi=$(docker inspect -f '{{.State.Pid}}' api)
pidFront=$(docker inspect -f '{{.State.Pid}}' frontend)

sudo nsenter -t $pidFront -n iptables -F

#Bloqueo de trafico icmp request de api a front
sudo nsenter -t $pidFront -n iptables -A INPUT -s $apiIp -p icmp --icmp-type echo-request -j DROP

#Bloque de trafico icmp de front a db
sudo nsenter -t $pidFront -n iptables -A OUTPUT -d $dbIp -p icmp -j DROP

