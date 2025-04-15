# orchestrator

This project implements a microservices architecture using Kubernetes. It consists of multiple services that work together to provide a complete application.

## Architecture Overview

The system consists of the following components:

- API Gateway
- Inventory Service with PostgreSQL database
- Billing Service with PostgreSQL database
- RabbitMQ Message Queue

## Prerequisites

- VirtualBox
- Vagrant
- kubectl
- Docker Engine

## Setup and Installation

1. Clone the repository

```bash
git clone https://01.kood.tech/git/mmumm/orchestrator.git && cd orchestrator
```

2. Set up the Kubernetes cluster
   Use the `orchestrator.sh` script to create and manage the Kubernetes cluster.

```bash
chmod +x orchestrator.sh
./orchestrator.sh create
```

This will:

- Create 2 VMs (master and agent)
- Install K3s on both nodes
- Set up the master-agent relationship
- Configure your local kubectl to connect to the cluster
- Applies manifests

3. Verify deployment

```bash
./orchestrator.sh status
```

### Using your own Docker Hub account

1. Build your Docker images and push them to Docker Hub.

```bash
chmod +x scripts/build-and-push.sh
./build-and-push.sh <your_dockerhub_username>
```

2. Update Docker image path in every manifest file.

```
image: <your_dockerhub_username>/billing-queue:latest
```

## Infrastructure management

Create the cluster and apply manifests

```bash
./orchestrator create
```

Start the cluster

```bash
./orchestrator start
```

Stop the cluster

```bash
./orchestrator stop
```

Delete the cluster

```bash
./orchestrator delete
```

Apply all manifests

```bash
./orchestrator apply
```

Check the status of the cluster

```bash
./orchestrator status
```

## API Documentation

Documentation is available at http://192.168.56.10:3000/api-docs

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

```
kubectl scale deployment billing-app --replicas=0
```

- Send an order.
- Verify that the `gateway-api` accepts it.
- Start the billing-app:

```
kubectl scale deployment billing-app --replicas=1
```

- Verify that the queued order appears in the database.
