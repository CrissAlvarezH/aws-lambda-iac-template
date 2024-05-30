# Descripción
Plantilla para crear la infraestructura usando aws cloudformation de una funcion lambda que es ejecutada usando un regla de expresión cron.

<img width="400px" src='https://github.com/CrissAlvarezH/aws-lambda-iac-template/blob/main/infra-diagram.png'/>

# Scripts
En el codigo puede encontrar un archivo `scripts.sh` el cual contiene el codigo necesario para deployar la infraestructura y manipularla

### Setup de la infraestructura

`sh scripts.sh setup-infra`

Este comando ejecuta un comando del `cli` de aws para crear el stack de cloud formation

### Actualizar infraestructura

`sh scripts.sh update-infra`

En caso de que realice cambios en `cloudformation.yaml` para que estos se vean reflejados en el stack de aws, este comando ejecutará esos cambios

### Eliminar infraestructura

`sh scripts.sh delete-infra`

### Desplegar aplicación

`sh scripts.sh deploy`

Este comando tomará el codigo (en este caso python) y lo empaquetará en un archivo `.zip` usando como nombre el hash del ultimo commit, luego
actualizará el codigo del lambda previamente creado usando este archivo comprimido.
El nombre del package lleva la estructua `package_<commit-hash>.zip`

### Empaquetar aplicación

`sh scripts.sh package <filename>`

Crea un archivo comprimido del codigo con el nombre pasado como ultimo argumento, exportandolo en la raiz del proyecto.
