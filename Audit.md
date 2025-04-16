#### What is container orchestration and what are the benefits?

Container orchestration is the automated process of managing, scaling and deploying containerized applications across multiple hosts.

Benefits:

- Automation
  - Reduces manual deployment and management effots.
- High Availability
  - Ensures apps remain running even if nodes fail.
- Scalability
  - Easily scale applications based on demand.
- Efficient Resource Usage
  - Optimizes CPU, memory and storage.
- Simplified Networking & Storage
  - Manages connectivity and persistent storage.

#### What is Kubernetes and what's its main role?

Kubernetes (K8s) is the most popular open-source container orchestration platform, originally developed by Google.

Main role of Kubernetes:

- Deploys & Manages containerized applications at scale.
- Automates Scaling & Failover - Self-healing (restarts failed containers).
- Load Balancing - Distributes network traffic efficiently.
- Supports Multi-Cloud & Hybrid Deployments - Runs on AWS, Azure, GCP, on-prem, etc.

#### What is K3s and what's its main role?

K3s is a lightweight, certified Kubernetes distribution designed for edge computing, IoT, and resource-constrained environments.

Main Role of K3s:

- Reduced Footprint - Uses less CPU/memory than standard K8s.

- Simplified Setup - Single binary, easy to install.

- Ideal for Edge & IoT - Runs on Raspberry Pi, ARM devices, etc.

- Fully Kubernetes-compatible - Works with standard K8s tools.

#### Creation of the cluster

![img](/image/create.png)

#### Cluster Nodes

![img](/image/nodes.png)

#### What is infrastructure as code and what are the advantages of it?

Infrastructure as Code (IaC) is the practice of managing and provisioning computing infrastructure (servers, networks, databases, etc.) using machine-readable configuration files (code) rather than manual processes.

Advatanges of IaC:

- Automation & Speed - Deploy infrastructure quickly and consistently.
- Version Control - Track changes using Git (e.g., GitHub, GitLab).
- Reproducibility - Eliminate "works on my machine" issues.
- Cost Efficiency - Reduce human errors and optimize resource usage.
- Scalability - Easily replicate environments (dev, staging, prod).
- Disaster Recovery - Quickly rebuild infrastructure from code.

#### What is a Kubernetes Manifest?

A Kubernetes Manifest is a YAML or JSON file that defines the desired state of a Kubernetes object (e.g., Pods, Deployments, Services). K8s uses these manifests to create, update, or delete resources.

#### Explain each K8s manifest.

api-gateway-app.yaml

- Defines a Deployment for the API Gateway (with an initContainer waiting for RabbitMQ) and a LoadBalancer Service to expose it externally, plus an HPA for auto-scaling based on CPU.

billing-app.yaml

- Deploys a StatefulSet for the Billing App (with an initContainer waiting for PostgreSQL) and a ClusterIP Service for internal communication.

billing-db.yaml

- Sets up a StatefulSet for PostgreSQL (with persistent storage, liveness/readiness probes) and a headless Service for direct pod access.

billing-queue.yaml

- Creates a StatefulSet for RabbitMQ (with persistent storage) and a headless Service for AMQP (queue) access.

inventory-app.yaml

- Manages a Deployment for the Inventory App (with an initContainer waiting for its DB) and a ClusterIP Service, plus an HPA for scaling.

inventory-db.yaml

- Configures a StatefulSet for the Inventory PostgreSQL DB (with persistent storage and probes) and a headless Service.

#### Check the secrets

![img](/image/secrets.png)

#### Check all deployed resources

![img](/image/rescources.png)

#### Information about the Cluster (StatefulSet, scaling etc)

![img](/image/fullresources.png)

#### What is StatefulSet in K8s?

A StatefulSet is a Kubernetes workload API object used to manage stateful applications (like databases, message queues) that require:

- Stable, unique network identifiers (e.g., pod-0, pod-1).

- Persistent storage (each pod gets its own PersistentVolume).

- Ordered, graceful deployment/scaling (pods are created/deleted sequentially).

Example use cases: PostgreSQL, MongoDB, RabbitMQ, Redis.

#### What is deployment in K8s?

A Deployment is a Kubernetes object that manages stateless applications by:

- Creating and scaling replica Pods.

- Handling rolling updates and rollbacks.

- Ensuring high availability (replaces failed Pods automatically).

Example use cases: Web servers (Nginx), APIs, microservices.

#### What is the difference between deployment and StatefulSet in K8s?

Deployments are used for stateless, scalable apps.
StatefulSets are used for stateful apps needing stable identities/storage.

#### What is scaling, and why do we use it?

Scaling adjusts the number of application instances (pods) to handle varying workloads.

- Horizontal scaling: adding more pods.
- Vertical scaling: increasing CPU/memory for existing pods.

#### What is a load balancer, and what is its role?

A Load Balancer distributes network traffic across multiple pods to:

- Prevent overload on any single instance.

- Improve availability (if a pod fails, traffic routes to others).

- Enable external access (for public-facing apps).

#### Why we don't put the database as a deployment?

Databases should not use Deployments because:

- No Stable Storage: Deployment Pods are ephemeral; data is lost if Pod restarts.

- No Fixed Identities: Pods get random names, breaking DNS/configurations.

- No Ordered Scaling: Concurrent DB replicas can corrupt data.

#### Inventory API requests

##### POST

![img](/image/inventory_1.png)

##### GET

![img](/image/inventory_2.png)

#### Billing API requests

##### Send a normal POST request.

![img](/image/billing_1.png)

##### Bring the billing-app down and send another request.

It doesn't get written to database, but stays in queue.

![img](/image/billing_2.png)

##### Bring the billing-app up and see if the previous request gets added to the database.

![img](/image/billing_3.png)
