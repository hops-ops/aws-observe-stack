# aws-observe-stack

Deploys the ObserveStack with AWS Pod Identity for OpenCost billing access.

## Overview

Composes the base `hops.ops.com.ai/ObserveStack` XRD with `aws.hops.ops.com.ai/PodIdentity`.
Automatically provisions IAM role and Pod Identity association for OpenCost's service account
with Cost Explorer, Pricing, CUR, and EC2 describe permissions.

## Usage

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: ObserveStack
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
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: ObserveStack
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

### Dedicated NodePool

Isolate observe workloads on a dedicated Karpenter NodePool (opt-in):

```yaml
spec:
  clusterName: my-cluster
  aws:
    region: us-east-1
  nodePool:
    enabled: true
```

When enabled:
- A Karpenter NodePool (`<clusterName>-observe`) is created with broad spot + on-demand instance selection
- Non-daemonset pods (Prometheus, Loki, Tempo, Grafana, OpenCost, VPA, Goldilocks) are scheduled to the NodePool via `nodeSelector` and `tolerations`
- Daemonsets (alloy-metrics, alloy-logs) continue to run on **all** nodes, including the observe NodePool

Custom NodePool settings:

```yaml
spec:
  nodePool:
    enabled: true
    nodeClassName: custom-nodeclass
    limits:
      nodes: 20
    requirements:
    - key: kubernetes.io/arch
      operator: In
      values: [amd64]
    - key: karpenter.sh/capacity-type
      operator: In
      values: [spot]
    disruption:
      consolidationPolicy: WhenEmpty
      consolidateAfter: "120s"
```

### Spot Instance Pricing

Enable accurate spot pricing in OpenCost by pointing it at a [SpotFeed](https://github.com/hops-ops/aws-spot-feed) bucket:

```yaml
spec:
  clusterName: my-cluster
  aws:
    region: us-east-1
  spotFeed:
    enabled: true
    bucketName: hops-root-account-spot-feed
    region: us-east-1
```

When enabled:
- OpenCost PodIdentity gets S3 read permissions for the spot feed bucket
- OpenCost exporter is configured with `spot_data_bucket`, `spot_data_region`, and spot node labels (`karpenter.sh/capacity-type=spot`)
- Optional `prefix` field if the spot feed uses an S3 key prefix

> **Prerequisite:** Deploy a `SpotFeed` XRD in the same AWS account first. See [aws-spot-feed](https://github.com/hops-ops/aws-spot-feed).

### Cloud Costs via CUR/Athena

Enable full AWS cloud cost ingestion in OpenCost by referencing a separately managed `CostReport` XR:

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: CostReport
metadata:
  name: hops-root-account
  namespace: default
spec:
  accountId: "123456789012"
  region: us-east-2
---
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: ObserveStack
metadata:
  name: observe
  namespace: default
spec:
  clusterName: production
  namespace: monitoring
  aws:
    region: us-east-2
  cloudCosts:
    enabled: true
    costReportRef:
      enabled: true
      name: hops-root-account
      accountId: "123456789012"
      region: us-east-2
```

When enabled:
- ObserveStack derives CUR/Athena names from the referenced `CostReport`
- OpenCost is wired through the chart's native `cloudIntegrationSecret` support
- The OpenCost PodIdentity gets Athena, Glue, and S3 permissions for the CUR bucket/workgroup
- The generated `cloud-integration.json` uses OpenCost's legacy flat AWS format with the Athena query-results location `s3://{bucketName}/athena-results`

`CostReport` is account-level and should be managed separately, one per AWS account. If your `CostReport` uses non-default names, set the corresponding overrides under `cloudCosts.costReportRef`. The legacy manual `cloudCosts` fields still work as a fallback.

## What Gets Created

1. **Helm Releases** - Prometheus, Loki, Tempo, k8s-monitoring/OpenCost, Grafana Operator, VPA, Goldilocks
2. **PodIdentity** - IAM role + Pod Identity association with billing permissions for OpenCost
3. **Usage** - deletion ordering: Observe deleted before PodIdentity
4. **StorageClasses** - gp3 EBS classes for Prometheus, Loki, Tempo (when using PVC storage)
5. **NodePool** *(opt-in)* - dedicated Karpenter NodePool for observe workloads

## Development

```bash
make render
make validate
make test
```
