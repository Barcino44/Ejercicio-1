# Ejercicio 1: Arquitectura Multi-Red Segura
## Objetivo: 
Implementar una arquitectura de tres niveles con aislamiento de red apropiado.
### Descripción:
 Crea una aplicación con las siguientes características:
- Un frontend (nginx) que debe ser accesible desde el host en el puerto 8080
- Un servicio API (puedes usar una imagen simple como httpd) que solo debe ser accesible desde el frontend
- Una base de datos (redis) que solo debe ser accesible desde el API
- Ningún contenedor excepto el frontend debe tener acceso a internet
- Los contenedores deben poder resolverse por nombre
### Prueba de éxito:
 - Debes poder acceder al frontend desde el host http://localhost:8080
 - Desde el frontend debes poder hacer ping al API por nombre
 - Desde el API debes poder hacer ping a la base de datos por nombre
 - El API NO debe poder hacer ping al frontend
 - Ni el API ni la base de datos deben poder hacer ping a 8.8.8.8

## Solución:
Sean los Dockerfile.
````
FROM nginx:latest
RUN apt update -y && apt upgrade -y && apt install iputils-ping -y
````
Que nos permiten instalar ping para realizar las pruebas.

Posteriormente, sea el comando.

````
sudo docker build -t frontendv1.0.0 .
sudo docker build -t apiv1.0.0 .
sudo docker build -t dbv1.0.0 .
````
Que nos permiten construir las imágenes de los contenedores.

Luego, se crean las redes.
````
sudo docker network create internet
sudo docker network create front-api --internal
sudo docker network create front-db --internal
sudo docker network create api-db --internal
````
Las anteriores redes son creadas para garantizar la resolución por nombre. Dos contenedores que se encuentren en la misma red pueden ser resueltos por nombre.

Posteriormente se ejecutan los contenedores.
````
docker run -d --name frontend --net -- internet --net front-api --net front-db -p 8080:80 frontendv1.0.0 
docker run -d --name api --net front-api --net api-db apiv1.0.0
docker run -d --name db --net front-db --net api-db dbv1.0.0
````
Finalmente para garantizar los reqs se ejecuta un script con iptables.
````
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
````
De esta manera:
- Se bloquea el tráfico proveniente de api en frontend (ICMP echo request).
- Se bloquea la comunicación db-front (Todo ICMP)
- Existe resolución por nombre con todos los contenedores (Los contenedores se pueden ver los unos con los otros en diferentes redes).
- No hay acceso a internet desde los contenedores que no son frontend (Pertenecen a redes interna).



