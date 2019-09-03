kubectl config set-cluster k8s_thw \
  --certificate-authority=generated/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=generated/admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=generated/admin.pem \
  --client-key=generated/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=generated/admin.kubeconfig

kubectl config set-context default \
  --cluster=k8s_thw \
  --user=admin \
  --kubeconfig=generated/admin.kubeconfig

kubectl config use-context default \
  --kubeconfig=generated/admin.kubeconfig
