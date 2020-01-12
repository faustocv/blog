---
layout: post
title:  "Configure a custom Helm v3 charts repository on GitHub"
date:   2020-01-10 00:00:00 +0000
categories: DevOps
lang: en
lang-ref: custom-helm-repo

---

On this occasion, I am going to explain how to configure a custom Helm charts repository on GitHub. If you are currently using Kubernetes and Helm, the chances are that you will probably need to adjust or change the preset chart's values, and also a way to persist those; so, that's when repositories come about.

Various options exist for repositories, listing some of them: GitHub, Google Cloud Storage, JFrog Artifactory, etc. It's worth mentioning that Docker Registry v2 supports hosting chart registries so that you could save charts in an OCI (Open Container Initiative) registry like Docker Hub if you are interested, read this [post](https://medium.com/@Oskarr3/giving-your-charts-a-home-in-docker-registry-d195d08e4eb3).

The example that I am covering in this post like be to fetch an NGINX chart, then to change some values, next to publish it and finally install the new chart.

## Prerequisites:

- Minikube or any Kubernetes cluster. The version that we are going to utilize in this post is 1.16.2.
- Helm v3.0. It's the latest released version of Helm. Check what's new in the following [link](https://helm.sh/blog/helm-3-released/).

## Steps:

The first step is to create a folder that is going to be used as a charts repository. I named it as **my-helm-repo**. After doing that, fetch the NGINX chart inside the previous folder, for doing so, type the command below.

```bash
$ cd ./my-helm-repo
$ helm pull --untar nginx/nginx-ingress
```

Next, adjust your chart as a convenience. For instance, I'll expand to 3 the number of replicas of the ingress controller deployment from the **values.yaml** file.

```yaml
controller:
  kind: deployment
...
## The number of replicas of the Ingress controller deployment.
replicaCount: 3
...
```

Then, package that chart into a versioned chart archive file. What is expected is to get an archive file in the current directory. Clean up your char repository deleting the original chart folder.

```bash
$ helm package ./nginx-ingress
$ rm -rf ./nginx-ingress
```

Now, generate an index yaml file based on the already existing chart archive. Notice that a point character is required; with this, we are telling to Helm use the current folder as a repository.

```bash
$ helm repo index .
```

Initialize git inside the **my-helm-repo** folder; also, commit everything that we've made so far and push it on a GitHub repository. Once you've uploaded the repository on Github, the next step is to add it to Helm.

```bash
$ helm repo add my-repo https://raw.githubusercontent.com/<YOUR_GITHUB_USERNAME>/my-helm-repo/master
$ helm repo update
```

You should get a successful message like this one:

```bash
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "my-repo" chart repository
...Successfully got an update from the "nginx" chart repository
Update Complete. ⎈ Happy Helming!⎈
```

Another way to see your repo is by telling Helm list all repositories which currently exist in your environment.

```bash
$ helm repo list

NAME    URL
nginx   https://helm.nginx.com/stable
my-repo https://raw.githubusercontent.com/<YOUR_GITHUB_USERNAME>/my-helm-repo/master
```

After that, install the customized chart in your Kubernetes cluster. Take in mind the chart comes from your new repository.

```bash
$ helm install my-nginx-server my-repo/nginx-ingress
```

Check if there are three replicas of the NGINX ingress controller. To do so, list pods by filtering the app label.

```bash
$ kubectl get pods -l app=my-nginx-server-nginx-ingress
```

The console output should look something like this:

```bash
NAME                                           READY   STATUS    RESTARTS   AGE
my-nginx-server-nginx-ingress-fcf4c5cf-dzlbj   1/1     Running   0          7m16s
my-nginx-server-nginx-ingress-fcf4c5cf-f5mnr   1/1     Running   0          7m16s
my-nginx-server-nginx-ingress-fcf4c5cf-jgtgs   1/1     Running   0          7m16s
```

What about if a new chart version is required to publish? If so, let's do an example of how this might look like. Fetch the chart again and modify the image tag value from **1.6.0** to **1.6.0-alpine** of the **values.yaml** file. Also, alter the **version** value of the **Chart.yaml** file from **0.4.0** to **0.4.1**. Then, create the archive **tgz** file, refresh the repository index,  and upload these changes on GitHub.

```bash
# fetch the last version of the chart
$ helm fetch my-repo/nginx-ingress --untar

# once required changes are made, create the archive file
$ helm package ./nginx-ingress

# delete the nginx-ingress folder
$ rm -rf nginx-ingress

# refresh the index file
$ helm repo index .

# make a commit and push it on GitHub
$ git add .
$ git commit -m "Uses Alpine based Docker image"
$ git push origin master
```

Finally, to get the new chart version in your repository is needed to run the update command.

```bash
$ helm repo update
```

Confirm if you got the last chart version.

```bash
$ helm search repo nginx

NAME                    CHART VERSION   APP VERSION     DESCRIPTION
my-repo/nginx-ingress   0.4.1           1.6.0           NGINX Ingress Controller
nginx/nginx-ingress     0.4.0           1.6.0           NGINX Ingress Control
```

If you want to see how the charts repository looks like, take a look at the [source code](https://github.com/faustocv/my-helm-repo).

## Wrap it up

Helm offers various repository options. Feel free to select the one that meets your necessities. If it is ok for you to have a public repository, GitHub is definitely a good option.

Helm 3 leverages Docker Registry v2 using its ability to save chart registries.

## Questions?
I'll appreciate any comment or question.

Thanks for reading.

Reach me out at <info@faustocv.org>
