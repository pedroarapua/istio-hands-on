
### Kubernetes

0. Create namespace
```bash
kubectl create namespace <YOUR-NAME-HERE>
```

1. Add <istio-injection=enabled> label to your Namespace
```bash
kubectl label namespace <YOUR-NAME-HERE> istio-injection=enabled
```

2. Set your Namespace as default
```bash
kubectl config set-context --current --namespace <YOUR-NAME-HERE>
```

3. Deploy Bets application
```bash
kubectl apply --recursive -f ./k8s
```

### Istio

1. Gateway (remember to edit the host YAML with your name)
```bash
kubectl apply -f ./istio/gateways
```

2. Virtual Service
```bash
kubectl apply -f ./istio/virtual_services
```

3. DR
```bash
kubectl apply -f ./istio/destination_rules
```

4. Traffic Control
```bash
kubectl apply -f ./istio/release
```

5. Fault Delay
```bash
kubectl apply -f ./istio/fault_injection/bets-delay-vs.yaml
```

5.1. Fault Error Code
```bash
kubectl apply -f ./istio/fault_injection/players-error-code-vs.yaml
```

6. Authn
```bash
kubectl apply -f ./istio/authn
```

7. Authz
```bash
kubectl apply -f ./istio/authz
```

```
├── k8s/                            -> app deployment
├── istio/                          -> istio configurations
│   ├── gateways/
│   ├── virtual_services/
│   ├── destination_rules/
│   └── release/
│   ├── fault_injection/
│   ├── authn/
│   └── authz/
└── scripts/
    ├── config-your-host.sh         -> replace all YAML templates with your default namespace
    ├── fwd-kiali.sh                -> forward port 20001 to Kiali
    ├── set-default-namespace.sh    -> set your default namespace
    └── curl/
        ├── bets.sh                 -> requests to bets service
        └── keycloak.sh             -> requests to authenticate on keycloak server
```
