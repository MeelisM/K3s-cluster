# K3s-cluster

This project implements a microservices architecture using Kubernetes. It consists of multiple services that work together to provide a complete application.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Setup and Installation](#setup-and-installation)
  - [Using your own Docker Hub account](#using-your-own-docker-hub-account)
- [Infrastructure Management](#infrastructure-management)
- [Components](#components)
  - [API Gateway (api-gateway-app)](#api-gateway-api-gateway-app)
  - [Inventory Service (inventory-app)](#inventory-service-inventory-app)
  - [Billing Service (billing-app)](#billing-service-billing-app)
  - [Databases](#databases)
  - [RabbitMQ Message Queue (billing-queue)](#rabbitmq-message-queue-billing-queue)
- [API Documentation](#api-documentation)
- [Postman Collections](#postman-collections)

## Architecture Overview

The system consists of the following components:

- API Gateway
- Inventory Service with PostgreSQL database
- Billing Service with PostgreSQL database
- RabbitMQ Message Queue

![Terminal output showing the status of Kubernetes nodes, pods, services, autoscaling and persistent volumes using orchestrator.sh script](/image/status.png "Kubernetes Cluster Status: Nodes, Pods, Services, Autoscaling, and Persistent Volumes")

## Prerequisites

- VirtualBox
- Vagrant
- kubectl
- Docker Engine (if using own Docker Hub account)

## Setup and Installation

1. Clone the repository

```bash
git clone https://github.com/MeelisM/K3s-cluster.git && cd K3s-cluter
```

2. Rename `.env-example` to `.env`

```bash
mv .env-example .env
```

3. Set up the Kubernetes cluster.<br>

Use the `scripts/orchestrator.sh` script to create and manage the Kubernetes cluster.

```bash
chmod +x scripts/orchestrator.sh
./scripts/orchestrator.sh create
```

This will:

- Create 2 VMs (master and agent)
- Install K3s on both nodes
- Set up the master-agent relationship
- Configure your local kubectl to connect to the cluster
- Apply manifests

4. Set the `KUBECONFIG` environment variable.
   This tells `kubectl` to use the correct kubeconfig file.

```bash
export KUBECONFIG=~/.kube/k3s-config
```

5.  Verify deployment.

```bash
./scripts/orchestrator.sh status
```

### Using your own Docker Hub account

This repository includes the `build-and-push.sh` script to build and push images to Docker Hub.

1. Build your Docker images and push them to Docker Hub.

```bash
chmod +x scripts/build-and-push.sh
./scripts/build-and-push.sh <your_dockerhub_username>
```

2. After building and pushing, you must update the image field in all Kubernetes manifest files with your Docker Hub username:

For example, in the manifests:

`image: <your_dockerhub_username>/billing-queue:latest`

This change needs to be made in each manifest.

Then execute the `./scripts/orchestrator.sh` script.

```bash
chmod +x scripts/orchestrator.sh
./scripts/orchestrator.sh create
```

## Infrastructure management

Create the cluster and apply manifests

```bash
./scripts/orchestrator create
```

Start the cluster

```bash
./scripts/orchestrator start
```

Stop the cluster

```bash
./scripts/orchestrator stop
```

Delete the cluster

```bash
./scripts/orchestrator delete
```

Apply all manifests

```bash
./scripts/orchestrator apply
```

Check the status of the cluster

```bash
./scripts/orchestrator status
```

## Components

### API Gateway (api-gateway-app)

- Port: 3000
- Description: Entry point for all client requests
- Auto-scales based on CPU usage (60%)
- Min replicas: 1, Max replicas: 3

### Inventory Service (inventory-app)

- Port: 8080
- Description: Manages movie inventory
- Auto-scales based on CPU usage (60%)
- Min replicas: 1, Max replicas: 3

### Billing Service (billing-app)

- Port: 8080
- Description: Processes orders through RabbitMQ queue
- Deployed as Statefulset

### Databases

- PostgreSQL Inventory Database (inventory-db)
  - Port: 5432
  - Deployed as StatefulSet with persistent storage
  - PostgreSQL Billing Database (billing-db)
  - Port: 5432
  - Deployed as StatefulSet with persistent storage

### RabbitMQ Message Queue (billing-queue)

- AMQP Port: 5672
- Management Port: 15672
- Description: Handles asynchronous communication between services

## API Documentation

Documentation is available at: [http://192.168.56.10:3000/api-docs](http://192.168.56.10:3000/api-docs)

## Postman Collections

This project includes a comprehensive Postman collection and environment for the testing of all API end points.

- Gateway Tests
  - Movies (CRUD operations)
  - Billing (Order creation)
- Test Suites
  - Movie CRUD sequence
    1. DELETE All Movies (Clean start)
    2. GET All Movies (Verify Empty)
    3. Create Movie
    4. Get Movie by ID
    5. Update Movie by ID
    6. Get Movie by Title
    7. Delete Movie by ID

To test the billing-queue functionality:

- Send an order while the billing-app is running.
  - Verify that the order appears in the database.
- Stop the billing-app:

`kubectl scale statefulset billing-app --replicas=0`

- Send an order.
- Verify that the `gateway-api` accepts it.
- Start the billing-app:

`kubectl scale statefulset billing-app --replicas=1`

- Verify that the queued order appears in the database.
