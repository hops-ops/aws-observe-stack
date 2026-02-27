# stack-aws-observe

Deploys the Observe stack with AWS Pod Identity for OpenCost billing access.

## Overview

Composes the base `stacks.hops.ops.com.ai/Observe` XRD with `aws.hops.ops.com.ai/PodIdentity`.
Automatically provisions IAM role and Pod Identity association for OpenCost's service account
with Cost Explorer, Pricing, CUR, and EC2 describe permissions.

## Usage

```yaml
apiVersion: stacks.aws.hops.ops.com.ai/v1alpha1
kind: Observe
metadata:
  name: observe
  namespace: default
spec:
  clusterName: my-cluster
  aws:
    region: us-east-1
```

Default storage is pvc-backed (`storage.type: pvc`) for both Loki and Tempo with auto-created `gp3` StorageClasses (`loki`, `tempo`).

You can set global StorageClass behavior and override per component:

```yaml
spec:
  storageClassDefaults:
    reclaimPolicy: Retain
  loki:
    storage:
      type: pvc
      size: 20Gi
      storageClass:
        name: logs
  tempo:
    storage:
      type: pvc
      storageClass:
        name: traces
```

With custom values:

```yaml
apiVersion: stacks.aws.hops.ops.com.ai/v1alpha1
kind: Observe
metadata:
  name: observe
  namespace: default
spec:
  clusterName: production-cluster
  namespace: monitoring
  loki:
    storage:
      type: s3
      s3:
        retentionDays: 30
  tempo:
    storage:
      type: s3
      s3:
        retentionDays: 14
  k8sMonitoring:
    values:
      opencost:
        enabled: true
  aws:
    region: us-west-2
    rolePrefix: prod-
```

## What Gets Created

1. `stacks.hops.ops.com.ai/Observe` - the base observability stack (Prometheus, Loki, Tempo, k8s-monitoring/OpenCost, Grafana)
2. `aws.hops.ops.com.ai/PodIdentity` - IAM role + Pod Identity association with billing permissions
3. `protection.crossplane.io/Usage` - deletion ordering: Observe deleted before PodIdentity

## Development

```bash
make render
make validate
make test
```
