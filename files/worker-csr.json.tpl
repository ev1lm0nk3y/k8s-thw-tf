{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "${city}",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "${state}"
    }
  ]
}
