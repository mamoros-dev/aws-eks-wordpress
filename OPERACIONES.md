# 1. Elimina el Ingress y su Load Balancer (evita que quede huérfano en AWS)
kubectl delete ingress wordpress-ingress -n wordpress

# 2. Desinstala el stack de monitorización (libera su volumen EBS)
helm uninstall monitoring -n monitoring

# 3. Desinstala WordPress y MySQL (libera sus volúmenes EBS)
helm uninstall wordpress -n wordpress
helm uninstall mysql -n wordpress

# 4. Desinstala el Ingress Controller (libera el Load Balancer de NGINX si no se borró solo)
helm uninstall ingress-nginx -n ingress-nginx

# 5. Verifica que no quedan volúmenes EBS colgando (importante, es lo que más factura si se olvida)
kubectl get pvc --all-namespaces
# Si aparece alguno, bórralo explícitamente:
# kubectl delete pvc <nombre> -n <namespace>

# 6. Ahora sí, destruye la infraestructura base (EKS, VPC, NAT Gateway) con Terraform
terraform destroy
