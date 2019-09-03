KUBERNETES_PUBLIC_ADDRESS="${1}"

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=generated/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=generated/kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=generated/kube-proxy.pem \
  --client-key=generated/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=generated/kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=k8s_thw \
  --user=system:kube-proxy \
  --kubeconfig=generated/kube-proxy.kubeconfig

kubectl config use-context default \
  --kubeconfig=generated/kube-proxy.kubeconfig

