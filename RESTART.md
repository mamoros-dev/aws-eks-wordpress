# 1. Recrea la infraestructura base con Terraform
terraform apply

# 2. Configura kubectl para apuntar al nuevo clúster (el endpoint/certificado cambia cada vez)
aws eks update-kubeconfig --name proyecto5-wordpress --region eu-west-1

# 3. Verifica que los nodos están Ready
kubectl get nodes

# 4. Recrea los Secrets (NO están en Git, se perdieron con el destroy)
kubectl create namespace wordpress

kubectl create secret generic mysql-root-secret \
  --namespace wordpress \
  --from-literal=mysql-root-password='TuPasswordSeguraAqui123!' \
  --from-literal=mysql-password='OtraPasswordSeguraAqui456!'

kubectl create secret generic wordpress-db-secret \
  --namespace wordpress \
  --from-literal=mariadb-password='OtraPasswordSeguraAqui456!'

# 5. Recrea la StorageClass (manifiesto YAML, no vive en Terraform)
kubectl apply -f storageclass.yaml

# 6. Reinstala todos los charts de Helm, en este orden
helm repo update

helm install mysql bitnami/mysql --namespace wordpress --values helm/mysql-values.yaml

# Espera a que mysql-0 esté Running antes de continuar
kubectl get pods -n wordpress -w

helm install wordpress bitnami/wordpress --namespace wordpress --values helm/wordpress-values.yaml \
  --set image.repository=bitnamilegacy/wordpress --set image.tag=latest \
  --set global.security.allowInsecureImages=true

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer

kubectl apply -f k8s/wordpress-ingress.yaml
kubectl apply -f k8s/wordpress-hpa.yaml

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword='TuPasswordGrafanaSeguraAqui!' \
  --set prometheus.prometheusSpec.retention=3d \
  --set prometheus.prometheusSpec.resources.requests.cpu=250m \
  --set prometheus.prometheusSpec.resources.requests.memory=512Mi \
  --set prometheus.prometheusSpec.resources.limits.memory=1Gi
