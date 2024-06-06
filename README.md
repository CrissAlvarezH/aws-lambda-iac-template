# Descripción
Plantilla para crear la infraestructura usando aws cloudformation de una funcion lambda que es ejecutada usando un regla de expresión cron.

<img width="400px" src='https://github.com/CrissAlvarezH/aws-lambda-iac-template/blob/main/infra-diagram.png'/>

# Variables de entorno

## Variables de infraestructura
Encontrarás un archivo `.env.infra.example` que hace referencia a las variables de entorno necesarias para los scripts
de IAC, el contenido es mostrado a continuación, debes copiarlo y pegarlo en un archivo `.env.infra` y 
establecer los valores que te interesen.
```
PROJECT_NAME="example-lambda"
CRON_EXECUTION_EXPRESSION="*/5 * * * ? *"
TIMEOUT=10
```
Cada vez que ejecutes alguno de los siguientes scripts estas variables serán leidas y usadas para su ejecución.

## Variables de aplicación
Por otro lado, las variables de entorno que necesite tu aplicacion deberan ser establecidas en un archivo llamado
`.env.app`, cuando el comando `sh scripts.sh deploy` se ejecute, estas variables seran cargadas en la función lambda, ademas puede
cargarlas en cualquier momento usando el comando `sh scripts.sh upload-env`.

# Scripts
En el codigo puede encontrar un archivo `scripts.sh` el cual contiene el codigo necesario para deployar la infraestructura y manipularla

### Setup de la infraestructura

`sh scripts.sh setup-infra`

Este comando ejecuta un comando del `cli` de aws para crear el stack de cloudformation.

### Actualizar infraestructura

`sh scripts.sh update-infra`

En caso de que realice cambios en `cloudformation.yaml` para que estos se vean reflejados en el stack de aws puede utilizar este comando.

### Eliminar infraestructura

`sh scripts.sh delete-infra`

### Desplegar aplicación

`sh scripts.sh deploy`

Este comando realizará lo siguiente:
1. Extraerá todas las dependencias del código para ser empaquetadas en un archivo llamado `package_<latest commit>.zip`
2. Agregará el codigo de `/app` en el paquete
3. Subirá este codigo empaquetado al lambda
4. Publicará una nueva version del lambda
5. Actualizará el alias **prod** para que apunte a la ultima versión

### Empaquetar aplicación

`sh scripts.sh package <filename>`

Crea un archivo comprimido del codigo y sus dependencias con el nombre pasado como ultimo argumento, exportandolo en la raiz del proyecto.
