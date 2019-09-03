kubectl config set-cluster k8s_thw \
  --certificate-authority=generated/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=generated/kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=generated/kube-controller-manager.pem \
  --client-key=generated/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=generated/kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=k8s_thw \
  --user=system:kube-controller-manager \
  --kubeconfig=generated/kube-controller-manager.kubeconfig

kubectl config use-context default \
  --kubeconfig=generated/kube-controller-manager.kubeconfig

