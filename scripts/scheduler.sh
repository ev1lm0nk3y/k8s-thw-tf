kubectl config set-cluster k8s_thw \
  --certificate-authority=generrated/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=generrated/kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=generrated/kube-scheduler.pem \
  --client-key=generrated/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=generrated/kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=k8s_thw \
  --user=system:kube-scheduler \
  --kubeconfig=generrated/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=generrated/kube-scheduler.kubeconfig
