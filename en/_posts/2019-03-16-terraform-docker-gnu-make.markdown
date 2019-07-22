---
layout: post
title:  "Speeding up Terraform setup with Docker and GNU Make"
date:   2019-03-16 00:00:00 +0000
categories: DevOps
lang: en
lang-ref: terraform-docker-gnu-make

---

The purpose of this post is to show you an example of how to set up a Terraform environment using Docker and GNU Make. That means it will not be necessary to install the Terraform package in your localhost, but we will use Docker instead.

The Terraform script will address a single task. It will automate the deployment of an NGINX server. Furthermore, the NGINX server will reside within a Docker container.

The code is available at [GitHub](https://github.com/faustocv/terraform_with_docker_and_make).

Let’s begin.

First, install Docker and GNU Make. You could get done this by browsing official website pages at [Docker's website](https://docs.docker.com/install/) and [Make's website](https://www.gnu.org/software/make/)

Second, create a folder named as **terraform-script**:

```bash
~ mkdir ~/terraform-script
```

Third, create a new file named **Makefile**. Place Makefile inside **terraform-script** folder:

```bash
~ cd /terraform-script
~ touch Makefile
```

Fourth, write the initialization task. This Make task will be used as a wrapper of init Terraform command. Terraform runs inside a Docker container. That container will be dropped after Terraform gets its initialization done, but how are we going to keep its outcome? The answer is volumes. Furthermore, this task is using a lightweight Terraform image that will download fast.

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

Once the previous task is written, execute it as follows:

```bash
~ make init
```

If things are going well you should get something like:

```
Terraform initialized in an empty directory!

The directory has no Terraform configuration files. You may begin working
with Terraform immediately by creating Terraform configuration files.
```


Fifth, build the **main.tf** file. After that, specify an image resource and a container resource. Notice that, in the case of image resource, the attribute **name** is assigned with the value: **nginx:1.15-alpine**. In contrast, in the case of container resource, the attribute **name** is assigned with the container name: **http_server**.

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

Sixth, add a new Make task in the Makefile. We'll name it as **apply** task. What it is worthy of explaining here is how Terraform spins up a new container from another; basically, the answer is volumes. Notice here we are sharing **docker.sock** file of the host with the container **terraform_apply**. The **docker.sock** contains useful information about how to communicate with the Docker Engine Service.

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

Then, execute the previous task as follows:

```bash
~ make apply
```

What is it expected to get from here is a successful message of two new resources that have been created:

```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Now, open the link [http://locahost:9080](http://locahost:9080) in any browser and check if NGINX is running. Another way to assert that is looking for a newly created containers using Docker CLI command:

```bash
~ docker ps
```

The expected outcome might look alike:
```
CONTAINER ID  IMAGE         COMMAND                  CREATED         STATUS         PORTS                 NAMES
52064dfa83a2  32a037976344  "nginx -g 'daemon of…"   4 seconds ago   Up 4 seconds   0.0.0.0:9080->80/tcp  http_server
```

Finally, add the last Make task in the Makefile. We'll name it as **destroy** task. This one will call the destroy function which let us clean up the containers and images built by Terraform.

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

Then, run it:

```bash
~ make destroy
```

The expected result should be something like:

```
Destroy complete! Resources: 2 destroyed.
```

## Wrap it up
1. Docker can be used for development. The most outstanding benefit is how quick can be the setup phase.
2. Creating containers from inside others containers is posible. The easy way to accomplish this is by means of sharing docker.sock file through volumes.
3. Terraform facilitates the management of Docker resources; for instance images and containers.

## Questions?
Reach me out at <info@faustocv.org>
