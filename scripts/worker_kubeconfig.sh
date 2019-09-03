NUM_WORKERS="$(echo "3-${1}" | bc)"
KUBERNETES_PUBLIC_ADDRESS="${2}"

for num in $(seq 0 "${NUM_WORKERS}"); do
  kubectl config set-cluster k8s_thw \
    --certificate-authority=generated/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=generates/worker-${num}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=generated/worker-${num}.pem \
    --client-key=generated/worker-${num}-key.pem \
    --embed-certs=true \
    --kubeconfig=generated/worker-${num}.kubeconfig

  kubectl config set-context default \
    --cluster=k8s_thw \
    --user=system:node:worker-${num} \
    --kubeconfig=generated/worker-${num}.kubeconfig

  kubectl config use-context default \
    --kubeconfig=generated/worker-${num}.kubeconfig
done

