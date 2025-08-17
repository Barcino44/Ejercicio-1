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
