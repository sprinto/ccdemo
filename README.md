# ccdemo
# How to setup a goproject for Code Camp

## Create Github repository
Create a new, empty, repository in Github.
In this example the repository will be github.com/babtist/ccdemo

Create an access token. This will be needed by the goreleaser (see below).
The access token is created here: https://github.com/settings/tokens
Store the access token in file.

## Create Go project and initialize Git

```
$ mkdir ccdemo
$ cd ccdemo
$ go mod init github.com/babtist/ccdemo
$ git init
$ git add go.mod  
$ git commit -m "first commit"
$ git branch -M main
$ git remote add origin https://github.com/babtist/ccdemo.git
$ git push -u origin main
```

## Create a docker repository
This is done in AWS. Please ask an administrator to assist with this.

## Add Go code
```
$ mkdir cmd
$ mkdir cmd/ccdemo
```

Add a main.go file in the `cmd/ccdemo` folder.
Example:
```
package main

import (
	"fmt"
	"time"
)

func main() {
	for {
		fmt.Println("Hello World!")
		time.Sleep(5 * time.Second)
	}
}
```

## Create Dockerfile
Create folder:
```
$ mkdir docker
```
Add Dockerfile:
```
FROM alpine:3.16.0
ADD ccdemo /usr/local/bin/ccdemo

ENTRYPOINT ["ccdemo"]
```

## Create goreleaser.yaml
Create a goreleaser.yaml on the top level in your folder.
Remember to change all occurences of `ccdemo` to the name of your project.

```
project_name: ccdemo
env_files:
  # This should point to the file where the github access token is stored
  github_token: ~/.github/token_codecamp
before:
  hooks:
    - go mod tidy
    # This will log into to AWS.
    - aws ecr get-login-password | docker login -u AWS --password-stdin "https://$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.$(aws configure get region).amazonaws.com"
builds:
  - env:
      - CGO_ENABLED=0
    goos:
      - linux
    id: ccdemo
    main: ./cmd/ccdemo  
    binary: ccdemo

release:
  disable: true

dockers:
  # Change image template to the name of your docker repository
  - image_templates: [ "571908524012.dkr.ecr.eu-north-1.amazonaws.com/babtist/ccdemo:{{ .Tag }}"]
    dockerfile: docker/Dockerfile
    goos: linux
    goarch: amd64
    ids:
    - ccdemo
    skip_push: false
```

## Create Helm chart
See example in `chart` folder.
Remember to change all occurences of `ccdemo` to the name of your project

## Commit and push your code
Commit and push the code you added above

## Release
Before releasing make sure that the image version in the `chart/values.yaml` file is updated with the version that your about to release. If not, update it, commit and push before doing the steps below.

```
# Create a tag. Note, should be the same as the image version on the chart/values.yaml file
$ git tag 0.0.1-beta1
# Push the tag
$ git push origin 0.0.1-beta1
# Run release pipeline.  This will build your code, create a docker image and push it to the docker regsitry
$ goreleaser release --rm-dist
```

## Deploy
This will deploy your app in our common Kubernetes cluster.

### Prerequisites 
* You have a kubeconfig for the cluster. Either it in the default kubeconfig file, `$HOME/.kube/config`, or store it in the `KUBECONFIG` environment variable.
* You have the AWS CLI tool installed and configured

### Create namespace (only first time)
Replace `ccdemo`below (two places) with the your app name.

```
$ kubectl create ns ccdemo

$ kubectl create secret docker-registry regcred \
  --docker-server=571908524012.dkr.ecr.eu-north-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=ccdemo
```

### Deploy app
This will deploy a Helm release with your app in the namespace you create above (ccdemo in this example)
```
$ helm upgrade --install -n ccdemo ccdemo chart
```

You can now view your application pod:
```
$ kubectl -n ccdemo get po
```

To view logs:
```
$ kubectl -n ccdemo logs -f <name-of-pod>
```