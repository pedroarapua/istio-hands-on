#!/bin/sh

set -x
set -e

wait() {
  echo "Waiting for $1"
  timeout -s TERM 45 bash -c "while [[ \"$(curl -s -o /dev/null -L -w \"%{http_code}\" ${0})\" != \"200\" ]]; do sleep 2; done" ${1}
  echo "Ready!"
  curl -I $1
}

# create registry container unless it already exists
reg_name='kind-registry'
reg_port='5000'
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "${reg_port}:5000" --name "${reg_name}" \
    registry:2
fi

# create a cluster with the local
cat <<EOF | kind create cluster --name istio-cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.19.1@sha256:98cf5288864662e37115e362b23e4369c8c4a408f99cbc06e58ac30ddc721600
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 30000
    hostPort: 80
  - containerPort: 30001
    hostPort: 443
  - containerPort: 30002
    hostPort: 15021
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_name}:${reg_port}"]
EOF

### connect the registry to the cluster network
#docker network connect "kind" "${reg_name}"

# tell https://tilt.dev to use the registry
# https://docs.tilt.dev/choosing_clusters.html#discovering-the-registry
for node in $(kind get nodes); do
  kubectl annotate node "${node}" "kind.x-k8s.io/registry=localhost:${reg_port}"
done

# connect to kind's cluster
kubectl cluster-info --context kind-istio-cluster

# install Istio
cat <<EOF | istioctl install -y -f -
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: demo
  components:
    egressGateways:
      - name: istio-egressgateway
        enabled: false
  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
        k8s:
          nodeSelector:
            ingress-ready: "true"
          service:
            ports:
              - name: status-port
                port: 15021
                targetPort: 15021
                nodePort: 30002
              - name: http2
                port: 80
                targetPort: 8080
                nodePort: 30000
              - name: https
                port: 443
                targetPort: 8443
                nodePort: 30001
  values:
    gateways:
      istio-ingressgateway:
        type: NodePort
EOF
