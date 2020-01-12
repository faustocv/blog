---
layout: post
title:  "Configura un repositorio de charts de Helm v3 en GitHub"
date:   2020-01-10 00:00:00 +0000
categories: DevOps
lang: es
lang-ref: custom-helm-repo

---

En esta ocasión, voy a explicar cómo configurar un repositorio personalizado de charts de Helm en Github. Si estás usando Kubernetes y Helm, tu probablemente necesitarás ajustar o cambiar los valores predefinidos de los charts, y también una forma de guardarlos; entonces, aquí es cuando los repositorios vienen a cabo.

Existen varias opciones de repositorios, vamos a listar algunos de ellos: GitHub, Google Cloud Storage, JFrog Artifactory, etcétera. Vale la pena mencionar que Docker Registry v2 soporta  repositorios de charts por lo que tu podrías guardar charts en un registry de OCI (Open Container Initiative, por sus siglas en inglés) como Docker Hub; si estás interesando, lee este [post](https://medium.com/@Oskarr3/giving-your-charts-a-home-in-docker-registry-d195d08e4eb3).

El ejemplo que voy a tratar en este post será descargar un chart de NGINX, luego cambiar algunos valores, siguiente publicarlo y finalmente instalar el nuevo chart.

## Prerrequisitos:

- Minikube o cualquier clúster de Kubernetes. La versión que vamos a utilizar en este post es la 1.16.2.
- Helm v3.0. Esa es la última versión liberada de Helm. Revisa que hay de nuevo en el siguiente [enlace](https://helm.sh/blog/helm-3-released/).

## Pasos:

El primer paso es crear una carpeta que va a ser usada como un repositorio de charts. Nombrar la carpeta como **my-helm-repo**. Después de hacer eso, descargar el chart de NGINX dentro de la carpeta anterior, para hacer eso ingresa el siguiente comando.

```bash
$ cd ./my-helm-repo
$ helm pull --untar nginx/nginx-ingress
```

Lo siguiente es cambiar tu chart a convenir. Por ejemplo, voy a incrementar a tres el número de réplicas del “ingress controller deployment” del archivo **values.yaml**.

```yaml
controller:
  kind: deployment
...
## The number of replicas of the Ingress controller deployment.
replicaCount: 3
...
```

Luego, empaquetar ese chart en un archivo comprimido y versionado. Lo que se espera es obtener un archivo comprimido en el directorio actual. Limpiar tu repositorio de charts borrando la carpeta del chart original.

```bash
$ helm package ./nginx-ingress
$ rm -rf ./nginx-ingress
```

Ahora, generar un archivo índice yaml basado en el archivo comprimido que ya existe. Tomar el cuenta que el punto (.) es requerido, con éste le estamos diciendo a Helm que use el directorio actual como un repositorio.

```bash
$ helm repo index .
```

Inicializar git dentro de la carpeta **my-helm-repo**, también hacer commit de todo lo que hemos hecho hasta ahora y subir los cambios en un repositorio de GitHub. Una vez que hayas subido el repositorio en GitHub, el siguiente paso es agregarlo a Helm.

```bash
$ helm repo add my-repo https://raw.githubusercontent.com/<YOUR_GITHUB_USERNAME>/my-helm-repo/master
$ helm repo update
```

Deberías obtener un mensaje exitoso como éste:

```bash
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "my-repo" chart repository
...Successfully got an update from the "nginx" chart repository
Update Complete. ⎈ Happy Helming!⎈
```

Otra manera de ver tu nuevo repositorio es diciéndole a Helm que enlista todos los repositorios que existen actualmente en tu ambiente local.

```bash
$ helm repo list

NAME    URL
nginx   https://helm.nginx.com/stable
my-repo https://raw.githubusercontent.com/<YOUR_GITHUB_USERNAME>/my-helm-repo/master
```
Luego de eso, instalar el chart personalizado en tu clúster de Kubernetes. Tomar en cuenta que el chart proviene de tu nuevo repositorio.

```bash
$ helm install my-nginx-server my-repo/nginx-ingress
```

Verificar si hay tres réplicas del “NGINX ingress controller”. Para hacer eso, enlista los pods filtrando por la etiqueta “app”.

```bash
$ kubectl get pods -l app=my-nginx-server-nginx-ingress
```

La salida de la consola debería presentar algo como lo siguiente:

```bash
NAME                                           READY   STATUS    RESTARTS   AGE
my-nginx-server-nginx-ingress-fcf4c5cf-dzlbj   1/1     Running   0          7m16s
my-nginx-server-nginx-ingress-fcf4c5cf-f5mnr   1/1     Running   0          7m16s
my-nginx-server-nginx-ingress-fcf4c5cf-jgtgs   1/1     Running   0          7m16s
```

Que tal si es necesario publicar una nueva versión del chart? En ese caso, hagamos un ejemplo de cómo sería eso. Descargar el chart de nuevo y modificar el valor de la etiqueta de la imagen de **1.6.0** a **1.6.0-alpine** en el archivo **values.yaml**. También, modificar el valor de la etiqueta **version** de **0.4.0** a **0.4.1** en el archivo **Chart.yaml**. Luego crear un archivo **tgz**, actualizar el índice del repositorio y subir esos cambios a GitHub.

```bash
# descargar la última versión del chart
$ helm fetch my-repo/nginx-ingress --untar

# una vez de que se hayan hecho los cambios, crear el archivo comprimido
$ helm package ./nginx-ingress

# eliminar la carpeta nginx-ingress
$ rm -rf nginx-ingress

# actualizar el índice
$ helm repo index .

# hacer commit y publicar en GitHub
$ git add .
$ git commit -m "Uses Alpine based Docker image"
$ git push origin master
```

Finalmente, para obtener la nueva versión del chart en tu repositorio, es necesario correr el comando de **update**.

```bash
$ helm repo update
```

Verificar si ya tienes la última versión del chart.

```bash
$ helm search repo nginx

NAME                    CHART VERSION   APP VERSION     DESCRIPTION
my-repo/nginx-ingress   0.4.1           1.6.0           NGINX Ingress Controller
nginx/nginx-ingress     0.4.0           1.6.0           NGINX Ingress Control
```

Si deseas ver cómo luce el repositorio de charts, echa un vistazo al [código fuente] (https://github.com/faustocv/my-helm-repo).

## En resumen

Helm ofrece varias opciones de repositorio. Siéntete en la libertad de seleccionar aquella que cumple con tus expectativas. Si esta bien para ti tener un repositorio público, entonces, GitHub es definitivamente una buena alternativa.

La versión 3 de Helm aprovecha la capacidad que tiene Docker Registry v2 para guardar registries de charts.

## Preguntas?
Apreciaré cualquier comentario o pregunta.

Gracias.

Contáctame vía correo <info@faustocv.org>
