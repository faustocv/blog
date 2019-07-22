---
layout: post
title:  "Rápida configuración de Terraform con Docker y GNU Make"
date:   2019-03-16 00:00:00 +0000
categories: DevOps
lang: es
lang-ref: terraform-docker-gnu-make

---

El propósito de este post es mostrar un ejemplo de cómo configurar un ambiente de Terraform utilizando Docker y Make de GNU. Eso significa que no será necesario instalar directamente el paquete de Terraform en tu host local sino que en su lugar se usará Docker.

El código de Terraform será dirigido en hacer una sola tarea. Este código automatizará el despliegue de un servidor web NGINX. Además, dicho servidor NGINX residirá en un contenedor de Docker.

El código está disponible en [GitHub](https://github.com/faustocv/terraform_with_docker_and_make).

Listo, empecemos.

Primero, instalar Docker y GNU Make, tu puedes hacer esto navegando hacia las páginas web oficiales de [Docker](https://docs.docker.com/install/) y [Make](https://www.gnu.org/software/make/)


Segundo, crear una carpeta a la que llamaremos **terraform-script**:

```bash
~ mkdir ~/terraform-script
```

Tercero, crear un archivo con el nombre **Makefile**. Ubicar el archivo Makefile dentro de la carpeta **terraform-script**:

```bash
~ cd /terraform-script
~ touch Makefile
```

Cuarto, escribir la tarea de inicialización (init) de Make. Esta tarea de Make será usada con un "wrapper" del comando "init" de Terraform. Terraform correrá dentro de un contenedor de Docker. Luego, ese contenedor será eliminado al momento de finalizar la tarea "init", pero ¿cómo guardaremos el resultado? la respuesta es la funcionalidad de volúmenes de Docker. Además, esta tarea usará una imagen ligera de Terraform la cual se descargará rápidamente. 

```
override TERRAFORM_IMAGE := hashicorp/terraform:light

init:
        docker container run \
                  --rm \
                  -it \
                  -v $(shell pwd):/app \
                  --name terraform_init \
                  -w /app \
                  $(TERRAFORM_IMAGE) \
                  init

```

Una vez que la tarea anterior ha sido escrita, ejecutar lo siguiente:

```bash
~ make init
```

Si todo va bien deberías obtener algo como:

```
Terraform initialized in an empty directory!

The directory has no Terraform configuration files. You may begin working
with Terraform immediately by creating Terraform configuration files.
```

Quinto, construir el archivo **main.tf**. Luego de eso, especificar los recursos de la imagen y el contenedor. Notar que, en el caso del recurso de la imagen, el atributo **name** está asignado con el valor de la imagen: **nginx:1.15-alpine**. Por el contrario, en el caso del recurso del contenedor, el atributo **name** está asginado con el nombre del contenedor: **http_server**.

```
resource "docker_image" "static_server_image" {
    name = "nginx:1.15-alpine"
}

resource "docker_container" "static_server_container" {
    name = "http_server"
    image = "${docker_image.static_server_image.latest}"
    ports {
        internal = "80"
        external = "9080"
    }
}
```

Sexto, agregar una nueva tarea Make en el archivo Makefile. La nombraremos como la tarea **apply**. Lo que es importante explicar aquí es ¿cómo Terraform inicializa un nuevo contenedor desde otro? básicamente, la respuesta es los volúmenes de Docker. Notar aquí que estamos compartiendo el archivo **docker.sock** del host al contenedor **terraform_apply**. El archivo **docker.sock** contiene información para  conectarse al servicio "Docker Engine".

```
apply:
        docker container run \
                  --rm \
                  -it \
                  -v $(shell pwd):/app \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  --name terraform_apply \
                  -w /app \
                  $(TERRAFORM_IMAGE) \
                  apply

```

Luego, ejecutar la siguiente tarea:

```bash
~ make apply
```

Lo que se espera obtener de aquí es un mensaje exitoso de que dos nuevos recursos han sido creados:

```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Ahora, abrir el enlace [http://locahost:9080](http://locahost:9080) en cualquier navegador y verificar si el servidor NGINX está corriendo. Otra forma de verificar es buscar los nuevos contenedores creados utilizando el siguiente comando CLI de Docker:

```bash
~ docker ps
```

El resultado esperado podría ser algo como:

```
CONTAINER ID  IMAGE         COMMAND                  CREATED         STATUS         PORTS                 NAMES
52064dfa83a2  32a037976344  "nginx -g 'daemon of…"   4 seconds ago   Up 4 seconds   0.0.0.0:9080->80/tcp  http_server
```

Finalmente, agregar la última tarea de Make en el archivo Makefile. La nombraremos como **destroy**. Esta tareá llamará a la función que limpia las imágenes y contenedores construidos por Terraform.

```
destroy:
        docker container run \
                  --rm \
                  -it \
                  -v $(shell pwd):/app \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  --name terraform_destroy \
                  -w /app \
                  $(TERRAFORM_IMAGE) \
                  destroy

```

Luego, ejecutar la tarea:

```bash
~ make destroy
```

El resultado esperado debería ser algo como:

```
Destroy complete! Resources: 2 destroyed.
```

## En resumen
1. Docker puede ser usado para desarrollo. El beneficio más sobresaliente es la rapidez con la que efectúa la fase de configuración.
2. La creación de contenedores desde el interior de otros es posible. La manera fácil de lograr esto es por medio de la compartición del  archivo docker.sock mediante volúmenes.
3. Terraform facilita la gestión de recursos de Docker, por ejemplo imágenes y contenedores.

## Preguntas?
Contáctame vía correo <info@faustocv.org>
