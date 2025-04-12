#!/bin/bash
usage() {
  echo "Usage: $0 [create|start|stop|delete|apply|status]"
  echo " create: Create the Kubernetes cluster"
  echo " start: Start the Kubernetes cluster"
  echo " stop: Stop the Kubernetes cluster"
  echo " delete: Delete the Kubernetes cluster"
  echo " apply: Apply all Kubernetes manifests"
  echo " status: Check the status of the Kubernetes cluster"
  exit 1
}

check_vagrant() {
  if ! command -v vagrant &> /dev/null; then
    echo "Vagrant is not installed. Please install Vagrant first."
    exit 1
  fi
}

check_kubectl() {
  if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install kubectl first."
    exit 1
  fi
}

create_cluster() {
  check_vagrant
  echo "Creating Kubernetes cluster..."
  vagrant up
  # Copy kubeconfig to local machine
  mkdir -p ~/.kube
  vagrant ssh master -c "sudo cat /etc/rancher/k3s/k3s.yaml" | sed 's/127.0.0.1/192.168.56.10/g' > ~/.kube/k3s-config
  export KUBECONFIG=~/.kube/k3s-config
  echo "To use kubectl with this cluster, run:"
  echo "export KUBECONFIG=~/.kube/k3s-config"
  echo "Cluster created"
  
  # After creating the cluster, apply manifests and set up the database
  apply_manifests
}

start_cluster() {
  check_vagrant
  echo "Starting Kubernetes cluster..."
  vagrant up
  echo "Cluster started"
}

stop_cluster() {
  check_vagrant
  echo "Stopping Kubernetes cluster..."
  vagrant halt
  echo "Cluster stopped"
}

delete_cluster() {
  check_vagrant
  echo "Deleting Kubernetes cluster..."
  vagrant destroy -f
  echo "Deleting K3s configuration..."
  rm -rf ~/.kube/k3s-config
  echo "Cluster and configuration deleted"
}

apply_manifests() {
  check_kubectl
  echo "Applying Kubernetes manifests..."
  export KUBECONFIG=~/.kube/k3s-config
  echo "======================================"
    echo "IMPORTANT: To use kubectl with this cluster, run:"
    echo "export KUBECONFIG=~/.kube/k3s-config"
    echo "Or add this line to your ~/.bashrc or ~/.zshrc file for permanent configuration"
    echo "======================================"
  kubectl apply -k .
  
  echo "Waiting for inventory-db pod to be ready..."
  kubectl wait --for=condition=ready pod -l app=inventory-db --timeout=180s
  
  echo "Checking database initialization..."
  DB_POD=$(kubectl get pods -l app=inventory-db -o jsonpath="{.items[0].metadata.name}")
  
  kubectl logs $DB_POD | grep "inventory-app database setup completed successfully"
  
  if [ $? -eq 0 ]; then
    echo "Database initialization successful!"
  else
    echo "Warning: Database initialization may not have completed successfully. Check logs for details."
    echo "Run 'kubectl logs $DB_POD' for more information."
  fi
  
  echo "Setup complete!"
}

check_status() {
  check_kubectl
  echo "Checking Kubernetes cluster status..."
  echo "Nodes:"
  kubectl get nodes -o wide
  echo ""
  echo "Pods:"
  kubectl get pods -A
  echo ""
  echo "Services:"
  kubectl get services -A
}

case "$1" in
  create)
    create_cluster
    ;;
  start)
    start_cluster
    ;;
  stop)
    stop_cluster
    ;;
  delete)
    delete_cluster
    ;;
  apply)
    apply_manifests
    ;;
  status)
    check_status
    ;;
  *)
    usage
    ;;
esac