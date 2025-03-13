# play-with-containers

This project implements a microservices architecture using Docker and Docker Compose. It consists of multiple services that work together to provide a complete application.

## Table of Contents

- [Core Technologies](#core-technologies)
- [Architecture Overview](#architecture-overview)
  - [Diagram](#diagram)
- [Prerequisites](#prerequisites)
- [Setup and Installation](#setup-and-installation)
- [Services](#services)
- [Usage](#usage)
- [Volumes](#volumes)
- [Networks](#networks)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Testing and Documentation Tools](#testing-and-documentation-tools)

## Core Technologies

- Node.js
- PostgreSQL
- RabbitMQ
- Docker / Docker Compose
- Postman

## Architecture Overview

The system consists of the following components:

- API Gateway
- Inventory Service with Database
- Billing Service with Database
- RabbitMQ Message Queue

### Diagram

![diagram](/image/diagram.png)

## Prerequisites

- Docker Engine (20.10.x or later)
- Docker Compose (2.x or later)

## Setup and Installation

### Clone the repository

```bash
git clone https://01.kood.tech/git/mmumm/play-with-containers.git && cd play-with-containers
```

### Rename `.env-example` to `.env` and add the missing values.

### Build and start the services.

```bash
docker compose up -d
```

### Verify all services are running.

```bash
docker compose ps -a
```

## Services

### API Gateway (api-gateway-app)

- Port: 3000
- Description: Entry point for all client requests
- Endpoints:
  - `/api/movies` - Forwards to Inventory Service
  - `/api/billing` - Forwards to Billing Service
  - `/api-docs` - API documentation

### Inventory Service (inventory-app)

- Port: 8080
- Description: Manages movie inventory
- Database: PostgreSQL (inventory-db)

### Billing Service (billing-app)

- Port: 8081
- Description: Processes orders through RabbitMQ queue
- Database: PostgreSQL (billing-db)

### Message Queue (rabbit-queue)

- Port: 5672 (AMQP)
- Description: Handles asynchronous communication between services

## Usage

### API Documentation

Documentation is available at `http://localhost:3000/api-docs`

### Accessing the API

All external requests can only access the `api-gateway-app` through port `3000`. Direct access to other services is not allowed.

The API is accessible at `http://localhost:3000/api`

## Volumes

The following volumes are created and maintained:

- `inventory-db-volume`: Persists inventory database data
- `billing-db-volume`: Persists billing database data
- `api-gateway-volume`: Stores API gateway logs

## Networks

All services are connected through the `app-network` bridge network.

## Monitoring and Maintenance

### Viewing Logs

```bash
docker compose logs [service_name]
```

### Restarting Services

```bash
docker compose restart [service_name]
```

### Stopping a Service

```bash
docker compose stop [service_name]
```

### Stopping the Environment

```bash
docker compose down
```

### Stopping the Environment and Removing: Images, Containers, Volumes and Networks.

```bash
docker compose down --volumes --rmi all --remove-orphans
```

## Testing and Documentation Tools

### Postman Collections

The project includes comprehensive Postman collections and environments for testing all API endpoints.

- Gateway Tests
  - Movies (CRUD operations)
  - Billing (Order creation)
- Test Suites
  - Movie CRUD sequence
    1. DELETE All Movies (Clean Start)
    2. GET All Movies (Verify Empty)
    3. Create Movie
    4. Get Movie by ID
    5. Update Movie by ID
    6. Get Movie by Title
    7. Delete Movie by ID

[Click to view Postman image](./image/postman.png)

### Testing RabbitMQ Queue

To test the billing queue functionality:

- Send order while billing-app is running

  - Verify order appears in database

- Stop billing-app container: `docker compose stop billing-app`

  - Send order
  - Verify Gateway accepts it

- Start billing-app container: `docker compose start billing-app`

  - Verify queued order appears in database
