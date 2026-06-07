import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# Unit tests for aws ObserveStack XRD
# ==============================================================================

_items = [
    # ==========================================================================
    # Test 1: Minimal input renders Helm Releases and PodIdentity
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-helm-releases-and-pod-identity"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kube-prometheus-stack"
                    spec.providerConfigRef = {
                        name = "my-cluster"
                        kind = "ProviderConfig"
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.forProvider.namespace = "monitoring"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "tempo"
                    spec.forProvider.namespace = "monitoring"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.namespace = "monitoring"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "grafana-operator"
                    spec.forProvider.namespace = "monitoring"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "vpa"
                    spec.forProvider.namespace = "monitoring"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "goldilocks"
                    spec.forProvider.namespace = "monitoring"
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-opencost"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-1"
                        serviceAccount = {
                            name = "opencost"
                            namespace = "monitoring"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 2: Custom namespace propagates to all resources
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-namespace-propagates"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "prod-cluster"
                    namespace = "observability"
                    aws = {
                        region = "us-west-2"
                        rolePrefix = "prod-"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kube-prometheus-stack"
                    spec.forProvider.namespace = "observability"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.forProvider.namespace = "observability"
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "tempo"
                    spec.forProvider.namespace = "observability"
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-opencost"
                    spec = {
                        rolePrefix = "prod-"
                        serviceAccount = {
                            namespace = "observability"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 3: User values merge into Helm Release
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "user-values-merge-into-release"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    k8sMonitoring = {
                        values = {
                            nodeExporter = {
                                enabled = True
                            }
                        }
                    }
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.values.nodeExporter.enabled = True
                }
            ]
        }
    }

    # ==========================================================================
    # Test 4: Provider config refs propagate correctly
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "provider-config-refs-propagate"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    helmProviderConfigRef = {
                        name = "custom-helm"
                        kind = "ClusterProviderConfig"
                    }
                    kubernetesProviderConfigRef = {
                        name = "custom-k8s"
                    }
                    awsProviderConfigRef = {
                        name = "custom-aws"
                    }
                    aws = {
                        region = "eu-west-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kube-prometheus-stack"
                    spec.providerConfigRef = {
                        name = "custom-helm"
                        kind = "ClusterProviderConfig"
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.providerConfigRef = {
                        name = "custom-helm"
                        kind = "ClusterProviderConfig"
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-opencost"
                    spec = {
                        providerConfigRef = {
                            name = "custom-aws"
                            kind = "ProviderConfig"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 5: OpenCost Usage renders when both resources are ready
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "opencost-usage-renders-when-both-ready"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            observedResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "k8s-monitoring"
                        annotations = {"crossplane.io/composition-resource-name" = "k8s-monitoring"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata = {
                        name = "observe-opencost"
                        annotations = {"crossplane.io/composition-resource-name" = "opencost-pod-identity"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
            ]
            assertResources = [
                {
                    apiVersion = "protection.crossplane.io/v1beta1"
                    kind = "Usage"
                    metadata.name = "observe-delete-k8s-monitoring-before-opencost-pod-identity"
                    spec = {
                        of = {
                            apiVersion = "eks.aws.m.upbound.io/v1beta1"
                            kind = "PodIdentityAssociation"
                            resourceRef.name = "my-cluster-observe-opencost"
                        }
                        by = {
                            apiVersion = "helm.m.crossplane.io/v1beta1"
                            kind = "Release"
                            resourceRef.name = "k8s-monitoring"
                        }
                        replayDeletion = True
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 6: S3 disabled by default — PVC storage values and StorageClasses
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "s3-disabled-pvc-storage-defaults"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.forProvider.values.singleBinary.persistence = {
                        enabled = True
                        storageClass = "loki"
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "tempo"
                    spec.forProvider.values.persistence = {
                        enabled = True
                        storageClass = "tempo"
                        storageClassName = "tempo"
                        size = "10Gi"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-loki-storageclass"
                    spec = {
                        forProvider = {
                            manifest = {
                                apiVersion = "storage.k8s.io/v1"
                                kind = "StorageClass"
                                metadata = {
                                    name = "loki"
                                }
                                provisioner = "ebs.csi.eks.amazonaws.com"
                                parameters = {
                                    type = "gp3"
                                    fsType = "ext4"
                                }
                            }
                        }
                        providerConfigRef = {
                            name = "my-cluster"
                            kind = "ProviderConfig"
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-tempo-storageclass"
                    spec = {
                        forProvider = {
                            manifest = {
                                apiVersion = "storage.k8s.io/v1"
                                kind = "StorageClass"
                                metadata = {
                                    name = "tempo"
                                }
                                provisioner = "ebs.csi.eks.amazonaws.com"
                                parameters = {
                                    type = "gp3"
                                    fsType = "ext4"
                                }
                            }
                        }
                        providerConfigRef = {
                            name = "my-cluster"
                            kind = "ProviderConfig"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 7: storageClassDefaults and per-component storageClass overrides apply
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "storageclass-defaults-and-overrides"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    storageClassDefaults = {
                        allowVolumeExpansion = False
                        reclaimPolicy = "Retain"
                        volumeBindingMode = "Immediate"
                        parameters = {
                            type = "gp3"
                            fsType = "xfs"
                        }
                    }
                    loki = {
                        storage = {
                            type = "pvc"
                            size = "20Gi"
                            storageClass = {
                                name = "logs-fast"
                                parameters = {
                                    type = "io2"
                                    fsType = "xfs"
                                }
                            }
                        }
                    }
                    tempo = {
                        storage = {
                            type = "pvc"
                            storageClass = {
                                name = "traces-fast"
                            }
                        }
                    }
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.forProvider.values.singleBinary.persistence = {
                        enabled = True
                        storageClass = "logs-fast"
                        size = "20Gi"
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "tempo"
                    spec.forProvider.values.persistence = {
                        enabled = True
                        storageClass = "traces-fast"
                        storageClassName = "traces-fast"
                        size = "10Gi"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-loki-storageclass"
                    spec.forProvider.manifest = {
                        apiVersion = "storage.k8s.io/v1"
                        kind = "StorageClass"
                        metadata = {
                            name = "logs-fast"
                        }
                        parameters = {
                            type = "io2"
                            fsType = "xfs"
                        }
                        allowVolumeExpansion = False
                        reclaimPolicy = "Retain"
                        volumeBindingMode = "Immediate"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-tempo-storageclass"
                    spec.forProvider.manifest = {
                        apiVersion = "storage.k8s.io/v1"
                        kind = "StorageClass"
                        metadata = {
                            name = "traces-fast"
                        }
                        parameters = {
                            type = "gp3"
                            fsType = "xfs"
                        }
                        allowVolumeExpansion = False
                        reclaimPolicy = "Retain"
                        volumeBindingMode = "Immediate"
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 8: Loki S3 enabled renders bucket, PodIdentity, and S3 values
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "loki-s3-enabled-renders-resources"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    loki = {
                        storage = {
                            type = "s3"
                            s3 = {
                                retentionDays = 30
                            }
                        }
                    }
                }
            }
            observedResources = [
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "Bucket"
                    metadata = {
                        name = "observe-loki-bucket"
                        annotations = {"crossplane.io/composition-resource-name" = "loki-bucket"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                        atProvider = {id = "observe-loki-storage"}
                    }
                }
                {
                    apiVersion = "kms.aws.m.upbound.io/v1beta1"
                    kind = "Key"
                    metadata = {
                        name = "observe-loki-storage"
                        annotations = {"crossplane.io/composition-resource-name" = "loki-storage-key"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                        atProvider = {
                            id = "12345678-1234-1234-1234-123456789012"
                            arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
                        }
                    }
                }
            ]
            assertResources = [
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "Bucket"
                    metadata.name = "observe-loki-bucket"
                    metadata.annotations = {
                        "crossplane.io/external-name" = "observe-loki-storage"
                    }
                    spec.forProvider.region = "us-east-1"
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "BucketPublicAccessBlock"
                    metadata.name = "observe-loki-bucket-pab"
                    spec.forProvider = {
                        blockPublicAcls = True
                        blockPublicPolicy = True
                        ignorePublicAcls = True
                        restrictPublicBuckets = True
                    }
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "BucketLifecycleConfiguration"
                    metadata.name = "observe-loki-bucket-lifecycle"
                    spec.forProvider.rule = [{
                        id = "expire-old-data"
                        status = "Enabled"
                        expiration = [{days = 37}]
                    }]
                }
                {
                    apiVersion = "kms.aws.m.upbound.io/v1beta1"
                    kind = "Key"
                    metadata.name = "observe-loki-storage"
                    spec.forProvider = {
                        enableKeyRotation = True
                        region = "us-east-1"
                    }
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "BucketServerSideEncryptionConfiguration"
                    metadata.name = "observe-loki-bucket-encryption"
                    spec.forProvider = {
                        bucketRef = {name = "observe-loki-bucket"}
                        region = "us-east-1"
                        rule = [{
                            applyServerSideEncryptionByDefault = {
                                kmsMasterKeyIdRef = {name = "observe-loki-storage"}
                                sseAlgorithm = "aws:kms"
                            }
                            bucketKeyEnabled = True
                        }]
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-loki"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-1"
                        serviceAccount = {
                            name = "loki"
                            namespace = "monitoring"
                        }
                        inlinePolicy = [{
                            name = "loki-s3-storage"
                            policy = """{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetBucketLocation", "s3:ListBucket", "s3:ListBucketMultipartUploads"],
      "Resource": "arn:aws:s3:::observe-loki-storage"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts"],
      "Resource": "arn:aws:s3:::observe-loki-storage/*"
    },
    {
      "Effect": "Allow",
      "Action": ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey", "kms:DescribeKey"],
      "Resource": "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "s3.us-east-1.amazonaws.com"
        }
      }
    }
  ]
}
"""
                        }]
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.forProvider.values.loki.storage = {
                        type = "s3"
                        bucketNames = {
                            chunks = "observe-loki-storage"
                            ruler = "observe-loki-storage"
                            admin = "observe-loki-storage"
                        }
                        s3 = {
                            region = "us-east-1"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 9: Tempo S3 enabled renders bucket, PodIdentity, and S3 values
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "tempo-s3-enabled-renders-resources"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-west-2"
                    }
                    tempo = {
                        storage = {
                            type = "s3"
                            retentionDays = 14
                        }
                    }
                }
            }
            observedResources = [
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "Bucket"
                    metadata = {
                        name = "observe-tempo-bucket"
                        annotations = {"crossplane.io/composition-resource-name" = "tempo-bucket"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                        atProvider = {id = "observe-tempo-storage"}
                    }
                }
                {
                    apiVersion = "kms.aws.m.upbound.io/v1beta1"
                    kind = "Key"
                    metadata = {
                        name = "observe-tempo-storage"
                        annotations = {"crossplane.io/composition-resource-name" = "tempo-storage-key"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                        atProvider = {
                            id = "12345678-1234-1234-1234-123456789012"
                            arn = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
                        }
                    }
                }
            ]
            assertResources = [
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "Bucket"
                    metadata.name = "observe-tempo-bucket"
                    metadata.annotations = {
                        "crossplane.io/external-name" = "observe-tempo-storage"
                    }
                    spec.forProvider.region = "us-west-2"
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "BucketPublicAccessBlock"
                    metadata.name = "observe-tempo-bucket-pab"
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "BucketLifecycleConfiguration"
                    metadata.name = "observe-tempo-bucket-lifecycle"
                    spec.forProvider.rule = [{
                        id = "expire-old-data"
                        status = "Enabled"
                        expiration = [{days = 21}]
                    }]
                }
                {
                    apiVersion = "kms.aws.m.upbound.io/v1beta1"
                    kind = "Key"
                    metadata.name = "observe-tempo-storage"
                    spec.forProvider = {
                        enableKeyRotation = True
                        region = "us-west-2"
                    }
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "BucketServerSideEncryptionConfiguration"
                    metadata.name = "observe-tempo-bucket-encryption"
                    spec.forProvider = {
                        bucketRef = {name = "observe-tempo-bucket"}
                        region = "us-west-2"
                        rule = [{
                            applyServerSideEncryptionByDefault = {
                                kmsMasterKeyIdRef = {name = "observe-tempo-storage"}
                                sseAlgorithm = "aws:kms"
                            }
                            bucketKeyEnabled = True
                        }]
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-tempo"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-west-2"
                        serviceAccount = {
                            name = "tempo"
                            namespace = "monitoring"
                        }
                        inlinePolicy = [{
                            name = "tempo-s3-storage"
                            policy = """{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetBucketLocation", "s3:ListBucket", "s3:ListBucketMultipartUploads"],
      "Resource": "arn:aws:s3:::observe-tempo-storage"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts"],
      "Resource": "arn:aws:s3:::observe-tempo-storage/*"
    },
    {
      "Effect": "Allow",
      "Action": ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey", "kms:DescribeKey"],
      "Resource": "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "s3.us-west-2.amazonaws.com"
        }
      }
    }
  ]
}
"""
                        }]
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "tempo"
                    spec.forProvider.values.tempo.storage.trace = {
                        backend = "s3"
                        s3 = {
                            bucket = "observe-tempo-storage"
                            endpoint = "s3.us-west-2.amazonaws.com"
                            region = "us-west-2"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 10: Custom bucket names are used
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-bucket-names"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    loki = {
                        storage = {
                            type = "s3"
                            s3 = {
                                bucketName = "my-custom-loki-bucket"
                            }
                        }
                    }
                    tempo = {
                        storage = {
                            type = "s3"
                            s3 = {
                                bucketName = "my-custom-tempo-bucket"
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "Bucket"
                    metadata.name = "observe-loki-bucket"
                    metadata.annotations = {
                        "crossplane.io/external-name" = "my-custom-loki-bucket"
                    }
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "Bucket"
                    metadata.name = "observe-tempo-bucket"
                    metadata.annotations = {
                        "crossplane.io/external-name" = "my-custom-tempo-bucket"
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.forProvider.values.loki.storage.bucketNames = {
                        chunks = "my-custom-loki-bucket"
                        ruler = "my-custom-loki-bucket"
                        admin = "my-custom-loki-bucket"
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "tempo"
                    spec.forProvider.values.tempo.storage.trace.s3.bucket = "my-custom-tempo-bucket"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 11: Loki S3 Usage renders when loki and loki-pod-identity are ready
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "loki-s3-usage-renders-when-ready"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    loki = {
                        storage = {
                            type = "s3"
                        }
                    }
                }
            }
            observedResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "loki"
                        annotations = {"crossplane.io/composition-resource-name" = "loki"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "kms.aws.m.upbound.io/v1beta1"
                    kind = "Key"
                    metadata = {
                        name = "observe-loki-storage"
                        annotations = {"crossplane.io/composition-resource-name" = "loki-storage-key"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                        atProvider = {
                            id = "12345678-1234-1234-1234-123456789012"
                            arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
                        }
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata = {
                        name = "observe-loki"
                        annotations = {"crossplane.io/composition-resource-name" = "loki-pod-identity"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
            ]
            assertResources = [
                {
                    apiVersion = "protection.crossplane.io/v1beta1"
                    kind = "Usage"
                    metadata.name = "observe-delete-loki-before-loki-pod-identity"
                    spec = {
                        of = {
                            apiVersion = "eks.aws.m.upbound.io/v1beta1"
                            kind = "PodIdentityAssociation"
                            resourceRef.name = "my-cluster-observe-loki"
                        }
                        by = {
                            apiVersion = "helm.m.crossplane.io/v1beta1"
                            kind = "Release"
                            resourceRef.name = "loki"
                        }
                        replayDeletion = True
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 12: Grafana datasources render when dependencies are ready
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "grafana-datasources-render-when-ready"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            observedResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "grafana-operator"
                        annotations = {"crossplane.io/composition-resource-name" = "grafana-operator"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "kube-prometheus-stack"
                        annotations = {"crossplane.io/composition-resource-name" = "kube-prometheus-stack"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "loki"
                        annotations = {"crossplane.io/composition-resource-name" = "loki"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "tempo"
                        annotations = {"crossplane.io/composition-resource-name" = "tempo"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata = {
                        name = "observe-grafana-instance"
                        annotations = {"crossplane.io/composition-resource-name" = "grafana-instance"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
            ]
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-grafana-instance"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "Grafana"
                        metadata.name = "grafana"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-datasource-prometheus"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDatasource"
                        metadata.name = "prometheus"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-datasource-loki"
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-datasource-tempo"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 13: Cross-component wiring — Loki/Tempo URLs in kube-prometheus-stack
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "cross-component-wiring"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.values.destinations = [
                        {name = "prometheus", type = "prometheus", url = "http://observe-prometheus.monitoring:9090/api/v1/write"}
                        {name = "loki", type = "loki", url = "http://loki-gateway.monitoring:80/loki/api/v1/push"}
                        {name = "tempo", type = "otlp", protocol = "grpc", url = "http://tempo.monitoring:4317"}
                    ]
                }
            ]
        }
    }

    # ==========================================================================
    # Test 14: Goldilocks user values merge with defaults (on-by-default preserved)
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "goldilocks-values-merge-preserves-defaults"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    goldilocks = {
                        values = {
                            controller = {
                                resources = {
                                    requests = {cpu = "48m", memory = "105M"}
                                    limits = {cpu = "3964m", memory = "665M"}
                                }
                            }
                            dashboard = {
                                replicas = 2
                                resources = {
                                    requests = {cpu = "15m", memory = "105M"}
                                    limits = {cpu = "115m", memory = "380M"}
                                }
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "goldilocks"
                    spec.forProvider.values = {
                        controller = {
                            flags = {"on-by-default" = "true"}
                            resources = {
                                requests = {cpu = "48m", memory = "105M"}
                                limits = {cpu = "3964m", memory = "665M"}
                            }
                        }
                        dashboard = {
                            enabled = True
                            flags = {"on-by-default" = "true"}
                            replicas = 2
                            resources = {
                                requests = {cpu = "15m", memory = "105M"}
                                limits = {cpu = "115m", memory = "380M"}
                            }
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 15: VPA user values merge with defaults (prometheus-address preserved)
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "vpa-values-merge-preserves-defaults"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    vpa = {
                        values = {
                            admissionController = {
                                replicas = 2
                            }
                            recommender = {
                                resources = {
                                    requests = {cpu = "15m", memory = "105M"}
                                }
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "vpa"
                    spec.forProvider.values = {
                        admissionController = {
                            replicas = 2
                        }
                        recommender = {
                            extraArgs = {
                                "prometheus-address" = "http://observe-prometheus.monitoring.svc:9090"
                                storage = "prometheus"
                            }
                            resources = {
                                requests = {cpu = "15m", memory = "105M"}
                            }
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 16: KPS user values merge with defaults (prometheus config preserved)
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "kps-values-merge-preserves-defaults"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    kubePrometheusStack = {
                        values = {
                            prometheus = {
                                prometheusSpec = {
                                    replicas = 2
                                    resources = {
                                        requests = {cpu = "500m", memory = "2Gi"}
                                    }
                                }
                            }
                            grafana = {
                                replicas = 2
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kube-prometheus-stack"
                    spec.forProvider.values.prometheus.enabled = True
                    spec.forProvider.values.prometheus.prometheusSpec.enableRemoteWriteReceiver = True
                    spec.forProvider.values.prometheus.prometheusSpec.replicas = 2
                    spec.forProvider.values.prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues = False
                    spec.forProvider.values.grafana.enabled = True
                    spec.forProvider.values.grafana.replicas = 2
                    spec.forProvider.values.alertmanager.enabled = True
                    spec.forProvider.values.nodeExporter.enabled = False
                }
            ]
        }
    }

    # ==========================================================================
    # Test 17: k8s-monitoring user values merge with defaults
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "k8s-monitoring-values-merge-preserves-defaults"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    k8sMonitoring = {
                        values = {
                            clusterMetrics = {
                                "node-exporter" = {
                                    resources = {
                                        requests = {cpu = "15m", memory = "105M"}
                                    }
                                }
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.values = {
                        clusterMetrics = {
                            enabled = True
                            "kube-state-metrics" = {deploy = False}
                            opencost = {
                                enabled = True
                                metricsSource = "prometheus"
                            }
                            "node-exporter" = {
                                resources = {
                                    requests = {cpu = "15m", memory = "105M"}
                                }
                            }
                        }
                        podLogs = {enabled = True}
                        nodeLogs = {enabled = True}
                        clusterEvents = {enabled = True}
                        "alloy-logs" = {enabled = True}
                        "alloy-metrics" = {
                            enabled = True
                            alloy.resources.requests = {
                                cpu = "200m"
                                memory = "2560Mi"
                            }
                        }
                        "alloy-receiver" = {enabled = True}
                        "alloy-singleton" = {enabled = True}
                        "alloy-operator" = {
                            resources.requests = {
                                cpu = "63m"
                                memory = "156Mi"
                            }
                        }
                        nodeExporter = {enabled = False}
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 18: Loki user values merge with defaults (gateway.enabled preserved)
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "loki-values-merge-preserves-defaults"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    loki = {
                        values = {
                            singleBinary = {
                                replicas = 2
                                resources = {
                                    requests = {cpu = "10m", memory = "750M"}
                                }
                            }
                            gateway = {
                                replicas = 2
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.forProvider.values.singleBinary.replicas = 2
                    spec.forProvider.values.singleBinary.persistence.enabled = True
                    spec.forProvider.values.gateway.enabled = True
                    spec.forProvider.values.gateway.replicas = 2
                    spec.forProvider.values.loki.auth_enabled = False
                    spec.forProvider.values.deploymentMode = "SingleBinary"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 19: Tempo user values merge with defaults (receivers preserved)
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "tempo-values-merge-preserves-defaults"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    tempo = {
                        values = {
                            tempo = {
                                memBallastSizeMbs = 256
                                resources = {
                                    requests = {cpu = "15m", memory = "105M"}
                                }
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "tempo"
                    spec.forProvider.values.tempo.memBallastSizeMbs = 256
                    spec.forProvider.values.tempo.searchEnabled = True
                    spec.forProvider.values.tempo.metricsGenerator.enabled = True
                    spec.forProvider.values.tempo.receivers.otlp.protocols.grpc.endpoint = "0.0.0.0:4317"
                    spec.forProvider.values.service.type = "ClusterIP"
                    spec.forProvider.values.persistence.enabled = True
                }
            ]
        }
    }

    # ==========================================================================
    # Test: HA mode renders replica defaults and disruption budgets
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "ha-mode-renders-replicas-topology-and-pdbs"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    ha = {
                        enabled = True
                    }
                    loki = {
                        storage = {type = "s3"}
                    }
                    tempo = {
                        storage = {type = "s3"}
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kube-prometheus-stack"
                    spec.forProvider.values.prometheus.prometheusSpec.replicas = 2
                    spec.forProvider.values.prometheus.prometheusSpec.topologySpreadConstraints = [{
                        maxSkew = 1
                        topologyKey = "topology.kubernetes.io/zone"
                        whenUnsatisfiable = "ScheduleAnyway"
                        labelSelector.matchLabels = {"app.kubernetes.io/name" = "prometheus"}
                    }]
                    spec.forProvider.values.alertmanager.alertmanagerSpec.replicas = 2
                    spec.forProvider.values.alertmanager.alertmanagerSpec.topologySpreadConstraints = [{
                        maxSkew = 1
                        topologyKey = "topology.kubernetes.io/zone"
                        whenUnsatisfiable = "ScheduleAnyway"
                        labelSelector.matchLabels = {"app.kubernetes.io/name" = "alertmanager"}
                    }]
                    spec.forProvider.values.grafana.replicas = 1
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.forProvider.values.singleBinary.replicas = 2
                    spec.forProvider.values.singleBinary.topologySpreadConstraints = [{
                        maxSkew = 1
                        topologyKey = "topology.kubernetes.io/zone"
                        whenUnsatisfiable = "ScheduleAnyway"
                        labelSelector.matchLabels = {
                            "app.kubernetes.io/name" = "loki"
                            "app.kubernetes.io/component" = "single-binary"
                        }
                    }]
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "tempo"
                    spec.forProvider.values.replicas = 2
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-pdb-prometheus"
                    spec.forProvider.manifest = {
                        apiVersion = "policy/v1"
                        kind = "PodDisruptionBudget"
                        metadata.name = "observe-prometheus"
                        metadata.namespace = "monitoring"
                        spec.minAvailable = 1
                        spec.selector.matchLabels = {"app.kubernetes.io/name" = "prometheus"}
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-pdb-loki"
                    spec.forProvider.manifest.spec.selector.matchLabels = {
                        "app.kubernetes.io/name" = "loki"
                        "app.kubernetes.io/component" = "single-binary"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-pdb-tempo"
                    spec.forProvider.manifest.spec.selector.matchLabels = {"app.kubernetes.io/name" = "tempo"}
                }
            ]
        }
    }

    # ==========================================================================
    # Test: HA mode keeps Loki and Tempo single-replica on PVC storage
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "ha-mode-keeps-pvc-loki-tempo-single-replica"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    ha = {
                        enabled = True
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.forProvider.values.singleBinary.replicas = 1
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "tempo"
                    spec.forProvider.values.persistence.enabled = True
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-pdb-loki"
                    spec.forProvider.manifest.spec.minAvailable = 1
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-pdb-tempo"
                    spec.forProvider.manifest.spec.minAvailable = 1
                }
            ]
        }
    }

    # ==========================================================================
    # Test: NodePool enabled renders NodePool object and scheduling constraints
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "nodepool-enabled-renders-nodepool-and-scheduling"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    nodePool = {
                        enabled = True
                    }
                }
            }
            assertResources = [
                # NodePool object is created
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-nodepool-observe"
                    spec.forProvider.manifest = {
                        apiVersion = "karpenter.sh/v1"
                        kind = "NodePool"
                        metadata.name = "hops-observe"
                        spec.template.metadata.labels = {
                            "workload-type" = "observe"
                        }
                        spec.template.spec.nodeClassRef = {
                            group = "eks.amazonaws.com"
                            kind = "NodeClass"
                            name = "hops-default"
                        }
                        spec.template.spec.taints = [
                            {key = "observe", value = "true", effect = "NoSchedule"}
                        ]
                        spec.template.spec.requirements = [
                            {key = "karpenter.sh/capacity-type", operator = "In", values = ["spot"]}
                            {key = "eks.amazonaws.com/instance-category", operator = "In", values = ["c", "m", "r", "t"]}
                            {key = "eks.amazonaws.com/instance-generation", operator = "Gte", values = ["4"]}
                            {key = "kubernetes.io/os", operator = "In", values = ["linux"]}
                        ]
                        spec.disruption = {
                            consolidationPolicy = "WhenEmptyOrUnderutilized"
                            consolidateAfter = "30s"
                            budgets = [{nodes = "100%"}]
                        }
                    }
                }
                # Prometheus gets nodeSelector + tolerations
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kube-prometheus-stack"
                    spec.forProvider.values.prometheus.prometheusSpec.nodeSelector = {
                        "workload-type" = "observe"
                    }
                    spec.forProvider.values.prometheus.prometheusSpec.tolerations = [
                        {key = "observe", value = "true", effect = "NoSchedule"}
                    ]
                }
                # Loki singleBinary gets nodeSelector + tolerations
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "loki"
                    spec.forProvider.values.singleBinary.nodeSelector = {
                        "workload-type" = "observe"
                    }
                    spec.forProvider.values.singleBinary.tolerations = [
                        {key = "observe", value = "true", effect = "NoSchedule"}
                    ]
                }
                # Tempo gets nodeSelector + tolerations
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "tempo"
                    spec.forProvider.values.nodeSelector = {
                        "workload-type" = "observe"
                    }
                    spec.forProvider.values.tolerations = [
                        {key = "observe", value = "true", effect = "NoSchedule"}
                    ]
                }
                # k8s-monitoring collectors get pinned scheduling when nodePool enabled
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.values = {
                        # alloy-metrics (StatefulSet) pinned to observe pool
                        "alloy-metrics" = {
                            enabled = True
                            controller = {
                                nodeSelector = {"workload-type" = "observe"}
                                tolerations = [
                                    {key = "observe", value = "true", effect = "NoSchedule"}
                                ]
                            }
                        }
                        # alloy-singleton pinned to observe pool
                        "alloy-singleton" = {
                            enabled = True
                            controller = {
                                nodeSelector = {"workload-type" = "observe"}
                                tolerations = [
                                    {key = "observe", value = "true", effect = "NoSchedule"}
                                ]
                            }
                        }
                        # alloy-receiver (DaemonSet) tolerates ALL taints — runs on every node
                        "alloy-receiver" = {
                            enabled = True
                            controller = {
                                tolerations = [
                                    {operator = "Exists"}
                                ]
                            }
                        }
                        # alloy-operator pinned to observe pool
                        "alloy-operator" = {
                            nodeSelector = {"workload-type" = "observe"}
                            tolerations = [
                                {key = "observe", value = "true", effect = "NoSchedule"}
                            ]
                        }
                        # opencost pinned to observe pool
                        clusterMetrics = {
                            enabled = True
                            "kube-state-metrics" = {deploy = False}
                            opencost = {
                                enabled = True
                                metricsSource = "prometheus"
                                opencost = {
                                    nodeSelector = {"workload-type" = "observe"}
                                    tolerations = [
                                        {key = "observe", value = "true", effect = "NoSchedule"}
                                    ]
                                }
                            }
                        }
                        # alloy-logs (DaemonSet) still tolerates ALL taints
                        "alloy-logs" = {
                            enabled = True
                            controller = {
                                tolerations = [
                                    {operator = "Exists"}
                                ]
                            }
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test: NodePool Usage protects NodePool from deletion until releases deleted
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "nodepool-usage-protects-deletion-order"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    nodePool = {
                        enabled = True
                    }
                }
            }
            observedResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata = {
                        name = "observe-nodepool-observe"
                        annotations = {"crossplane.io/composition-resource-name" = "nodepool-observe"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "kube-prometheus-stack"
                        annotations = {"crossplane.io/composition-resource-name" = "kube-prometheus-stack"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "loki"
                        annotations = {"crossplane.io/composition-resource-name" = "loki"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "tempo"
                        annotations = {"crossplane.io/composition-resource-name" = "tempo"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
            ]
            assertResources = [
                # Usage: kube-prometheus-stack must be deleted before nodepool
                {
                    apiVersion = "protection.crossplane.io/v1beta1"
                    kind = "Usage"
                    metadata.name = "observe-delete-kube-prometheus-stack-before-nodepool"
                    spec = {
                        of = {
                            apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                            kind = "Object"
                            resourceRef.name = "observe-nodepool-observe"
                        }
                        by = {
                            apiVersion = "helm.m.crossplane.io/v1beta1"
                            kind = "Release"
                            resourceRef.name = "kube-prometheus-stack"
                        }
                        replayDeletion = True
                    }
                }
                # Usage: loki must be deleted before nodepool
                {
                    apiVersion = "protection.crossplane.io/v1beta1"
                    kind = "Usage"
                    metadata.name = "observe-delete-loki-before-nodepool"
                    spec = {
                        of = {
                            apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                            kind = "Object"
                            resourceRef.name = "observe-nodepool-observe"
                        }
                        by = {
                            apiVersion = "helm.m.crossplane.io/v1beta1"
                            kind = "Release"
                            resourceRef.name = "loki"
                        }
                        replayDeletion = True
                    }
                }
                # Usage: tempo must be deleted before nodepool
                {
                    apiVersion = "protection.crossplane.io/v1beta1"
                    kind = "Usage"
                    metadata.name = "observe-delete-tempo-before-nodepool"
                    spec = {
                        of = {
                            apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                            kind = "Object"
                            resourceRef.name = "observe-nodepool-observe"
                        }
                        by = {
                            apiVersion = "helm.m.crossplane.io/v1beta1"
                            kind = "Release"
                            resourceRef.name = "tempo"
                        }
                        replayDeletion = True
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test: NodePool disabled (default) renders no NodePool object
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "nodepool-disabled-no-nodepool-object"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                # No nodeSelector on Prometheus when nodePool disabled
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kube-prometheus-stack"
                    spec.forProvider.values.prometheus.prometheusSpec = {
                        enableRemoteWriteReceiver = True
                        retention = "30d"
                        serviceMonitorSelectorNilUsesHelmValues = False
                        podMonitorSelectorNilUsesHelmValues = False
                        ruleSelectorNilUsesHelmValues = False
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test: Spot feed enabled wires OpenCost Helm values and adds IAM policy
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "spot-feed-enabled-wires-opencost"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws.region = "us-west-2"
                    spotFeed = {
                        enabled = True
                        bucketName = "my-spot-bucket"
                        accountId = "123456789012"
                        region = "us-west-2"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.values.clusterMetrics.opencost.opencost.customPricing = {
                        enabled = True
                        provider = "aws"
                        costModel = {
                            awsSpotDataBucket = "my-spot-bucket"
                            awsSpotDataRegion = "us-west-2"
                            projectID = "123456789012"
                            spotLabel = "karpenter.sh/capacity-type"
                            spotLabelValue = "spot"
                        }
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-opencost"
                    spec.inlinePolicy = [
                        {
                            name = "opencost-billing"
                        }
                        {
                            name = "opencost-spot-feed-s3-read"
                        }
                    ]
                }
            ]
        }
    }

    # ==========================================================================
    # Test: Spot feed disabled (default) — no aws config in OpenCost values
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "spot-feed-disabled-no-aws-config"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws.region = "us-east-1"
                }
            }
            assertResources = [
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-opencost"
                    spec.inlinePolicy = [
                        {
                            name = "opencost-billing"
                        }
                    ]
                }
            ]
        }
    }

    # ==========================================================================
    # Test: Cloud costs enabled wires OpenCost Helm values, secret, and IAM
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "cloud-costs-enabled-wires-opencost"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws.region = "us-east-2"
                    cloudCosts = {
                        enabled = True
                        bucketName = "my-account-cur"
                        accountId = "123456789012"
                        region = "us-east-2"
                        databaseName = "my_account_cur"
                        tableName = "my_account_cur"
                        workgroupName = "my-account-cur-workgroup"
                    }
                }
            }
            assertResources = [
                # OpenCost Helm values should use the native cloudIntegrationSecret wiring
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.values.clusterMetrics.opencost.opencost = {
                        cloudCost = {
                            enabled = True
                        }
                        cloudIntegrationSecret = "opencost-cloud-integration"
                        customPricing = {
                            enabled = True
                            provider = "aws"
                            costModel = {
                                athenaBucketName = "s3://my-account-cur/athena-results"
                                athenaRegion = "us-east-2"
                                athenaDatabase = "my_account_cur"
                                athenaTable = "my_account_cur"
                                athenaWorkgroup = "my-account-cur-workgroup"
                                athenaProjectID = "123456789012"
                                projectID = "123456789012"
                            }
                        }
                        exporter = {
                            image = {
                                tag = "1.120.0"
                            }
                            extraEnv = {
                                CLOUD_COST_CONFIG_PATH = "/var/configs/cloud-integration/cloud-integration.json"
                                PLUGIN_CONFIG_DIR = "/var/configs"
                            }
                        }
                        ui = {
                            image = {
                                tag = "1.120.0"
                            }
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-cloud-integration-secret"
                    spec.forProvider.manifest = {
                        apiVersion = "v1"
                        kind = "Secret"
                        metadata = {
                            name = "opencost-cloud-integration"
                            namespace = "monitoring"
                        }
                        data = {
                            "cloud-integration.json" = "eyJhd3MiOlt7ImF0aGVuYUJ1Y2tldE5hbWUiOiJzMzovL215LWFjY291bnQtY3VyL2F0aGVuYS1yZXN1bHRzIiwiYXRoZW5hUmVnaW9uIjoidXMtZWFzdC0yIiwiYXRoZW5hRGF0YWJhc2UiOiJteV9hY2NvdW50X2N1ciIsImF0aGVuYVRhYmxlIjoibXlfYWNjb3VudF9jdXIiLCJhdGhlbmFXb3JrZ3JvdXAiOiJteS1hY2NvdW50LWN1ci13b3JrZ3JvdXAiLCJwcm9qZWN0SUQiOiIxMjM0NTY3ODkwMTIifV19"
                        }
                    }
                }
                # PodIdentity should have Athena IAM policy
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-opencost"
                    spec.inlinePolicy = [
                        {
                            name = "opencost-billing"
                        }
                        {
                            name = "opencost-cloud-costs-athena"
                        }
                    ]
                }
            ]
        }
    }

    # ==========================================================================
    # Test: Cloud integration secret follows the k8s-monitoring namespace
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "cloud-costs-secret-uses-k8s-monitoring-namespace"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    namespace = "observability"
                    aws.region = "us-east-2"
                    k8sMonitoring.namespace = "cost-monitoring"
                    cloudCosts = {
                        enabled = True
                        bucketName = "my-account-cur"
                        accountId = "123456789012"
                        region = "us-east-2"
                        databaseName = "my_account_cur"
                        tableName = "my_account_cur"
                        workgroupName = "my-account-cur-workgroup"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.namespace = "cost-monitoring"
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-cloud-integration-secret"
                    spec.forProvider.manifest = {
                        apiVersion = "v1"
                        kind = "Secret"
                        metadata = {
                            name = "opencost-cloud-integration"
                            namespace = "cost-monitoring"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test: CostReport reference derives cloud cost integration values
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "cloud-costs-cost-report-ref-derives-values"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                metadata.namespace = "default"
                spec = {
                    clusterName = "my-cluster"
                    aws.region = "us-east-2"
                    cloudCosts = {
                        enabled = True
                        costReportRef = {
                            enabled = True
                            name = "hops-root-account"
                            accountId = "123456789012"
                            region = "us-east-2"
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.values.clusterMetrics.opencost.opencost = {
                        cloudCost = {
                            enabled = True
                        }
                        cloudIntegrationSecret = "opencost-cloud-integration"
                        customPricing = {
                            enabled = True
                            provider = "aws"
                            costModel = {
                                athenaBucketName = "s3://hops-root-account-cur/athena-results"
                                athenaRegion = "us-east-2"
                                athenaDatabase = "hops_root_account_cur"
                                athenaTable = "hops_root_account_cur"
                                athenaWorkgroup = "hops-root-account-cur-workgroup"
                                athenaProjectID = "123456789012"
                                projectID = "123456789012"
                            }
                        }
                        exporter = {
                            image = {
                                tag = "1.120.0"
                            }
                            extraEnv = {
                                CLOUD_COST_CONFIG_PATH = "/var/configs/cloud-integration/cloud-integration.json"
                                PLUGIN_CONFIG_DIR = "/var/configs"
                            }
                        }
                        ui = {
                            image = {
                                tag = "1.120.0"
                            }
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-cloud-integration-secret"
                    spec.forProvider.manifest = {
                        apiVersion = "v1"
                        kind = "Secret"
                        metadata = {
                            name = "opencost-cloud-integration"
                            namespace = "monitoring"
                        }
                        data = {
                            "cloud-integration.json" = "eyJhd3MiOlt7ImF0aGVuYUJ1Y2tldE5hbWUiOiJzMzovL2hvcHMtcm9vdC1hY2NvdW50LWN1ci9hdGhlbmEtcmVzdWx0cyIsImF0aGVuYVJlZ2lvbiI6InVzLWVhc3QtMiIsImF0aGVuYURhdGFiYXNlIjoiaG9wc19yb290X2FjY291bnRfY3VyIiwiYXRoZW5hVGFibGUiOiJob3BzX3Jvb3RfYWNjb3VudF9jdXIiLCJhdGhlbmFXb3JrZ3JvdXAiOiJob3BzLXJvb3QtYWNjb3VudC1jdXItd29ya2dyb3VwIiwicHJvamVjdElEIjoiMTIzNDU2Nzg5MDEyIn1dfQ=="
                        }
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-opencost"
                    spec.inlinePolicy = [
                        {
                            name = "opencost-billing"
                        }
                        {
                            name = "opencost-cloud-costs-athena"
                        }
                    ]
                }
            ]
        }
    }

    # ==========================================================================
    # Test: Cloud costs disabled (default) — no secret, no Athena IAM
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "cloud-costs-disabled-no-secret"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws.region = "us-east-1"
                }
            }
            assertResources = [
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-opencost"
                    spec.inlinePolicy = [
                        {
                            name = "opencost-billing"
                        }
                    ]
                }
            ]
        }
    }

    # ==========================================================================
    # exposure: enabled composes the full bridge — Zitadel ExternalSecret,
    # ProviderConfig, OIDC App, Redis, oauth2-proxy, Waypoint, sister Services,
    # HTTPRoutes, AuthorizationPolicy.CUSTOM.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "exposure-enabled-composes-full-bridge"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    namespace = "monitoring"
                    aws.region = "us-east-1"
                    auth = {
                        issuerURL = "https://auth.example.com"
                        awsSecretsManagerPath = "push/my-cluster/zitadel-credentials"
                        zitadelProjectId = "330000000000000001"
                    }
                    exposure = {
                        enabled = True
                        domain = "observe.example.com"
                        extensionProviderName = "monitoring-oauth2-proxy"
                        oauth2Proxy.cookieSecretRef.name = "observe-oauth2-proxy-cookie"
                        prometheus = {
                            enabled = True
                            host = "prometheus.observe.example.com"
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-zitadel-credentials"
                    spec.forProvider.manifest = {
                        apiVersion = "external-secrets.io/v1"
                        kind = "ExternalSecret"
                        metadata.name = "zitadel-credentials"
                        metadata.namespace = "monitoring"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-zitadel-providerconfig"
                    spec.forProvider.manifest = {
                        apiVersion = "zitadel.m.crossplane.io/v1beta1"
                        kind = "ProviderConfig"
                        metadata.name = "zitadel-observe-stack"
                        metadata.namespace = "monitoring"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-oidc-app"
                    spec.forProvider.manifest = {
                        apiVersion = "application.zitadel.m.crossplane.io/v1alpha1"
                        kind = "Oidc"
                        metadata.name = "monitoring-oauth2-proxy"
                        spec = {
                            forProvider.projectId = "330000000000000001"
                            forProvider.appType = "OIDC_APP_TYPE_WEB"
                            forProvider.redirectUris = ["https://prometheus.observe.example.com/oauth2/callback"]
                            writeConnectionSecretToRef.name = "monitoring-oauth2-proxy-oidc-client"
                            providerConfigRef.name = "zitadel-observe-stack"
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-redis-sts"
                    spec.forProvider.manifest = {
                        apiVersion = "apps/v1"
                        kind = "StatefulSet"
                        metadata.name = "monitoring-oauth2-proxy-redis"
                        metadata.namespace = "monitoring"
                        spec.replicas = 1
                        spec.template.spec.containers = [
                            {
                                name = "redis"
                                image = "mirror.gcr.io/redis:7-alpine"
                                resources = {
                                    requests = {cpu = "15m", memory = "100Mi"}
                                    limits = {cpu = "100m", memory = "256Mi"}
                                }
                            }
                        ]
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-oauth2-proxy-svc"
                    spec.forProvider.manifest = {
                        apiVersion = "v1"
                        kind = "Service"
                        metadata.name = "monitoring-oauth2-proxy"
                        metadata.namespace = "monitoring"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-oauth2-proxy-deploy"
                    spec.forProvider.manifest.spec.template.spec.containers = [
                        {
                            name = "oauth2-proxy"
                            resources = {
                                requests = {cpu = "15m", memory = "100Mi"}
                                limits = {cpu = "100m", memory = "256Mi"}
                            }
                        }
                    ]
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-waypoint"
                    spec.forProvider.manifest = {
                        apiVersion = "gateway.networking.k8s.io/v1"
                        kind = "Gateway"
                        metadata.name = "monitoring-waypoint"
                        metadata.namespace = "monitoring"
                        metadata.labels = {
                            "istio.io/waypoint-for" = "service"
                        }
                        spec.gatewayClassName = "istio-waypoint"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-sister-svc-prometheus"
                    spec.forProvider.manifest = {
                        apiVersion = "v1"
                        kind = "Service"
                        metadata.name = "exposure-prometheus"
                        metadata.namespace = "monitoring"
                        metadata.labels = {
                            "istio.io/use-waypoint" = "monitoring-waypoint"
                            "istio.io/ingress-use-waypoint" = "true"
                        }
                        spec.selector = {
                            "app.kubernetes.io/name" = "prometheus"
                            prometheus = "kube-prometheus-stack-prometheus"
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-httproute-prometheus"
                    spec.forProvider.manifest = {
                        apiVersion = "gateway.networking.k8s.io/v1"
                        kind = "HTTPRoute"
                        metadata.name = "exposure-prometheus"
                        spec = {
                            hostnames = ["prometheus.observe.example.com"]
                            parentRefs = [
                                {
                                    name = "platform"
                                    namespace = "istio-ingress"
                                    sectionName = "http"
                                }
                                {
                                    name = "platform"
                                    namespace = "istio-ingress"
                                    sectionName = "https-apex"
                                }
                            ]
                            rules = [
                                {
                                    matches = [{ path = { type = "PathPrefix", value = "/oauth2" } }]
                                    backendRefs = [{
                                        name = "monitoring-oauth2-proxy"
                                        namespace = "monitoring"
                                        port = 4180
                                    }]
                                }
                                {
                                    matches = [{ path = { type = "PathPrefix", value = "/" } }]
                                    backendRefs = [{
                                        name = "exposure-prometheus"
                                        namespace = "monitoring"
                                        port = 9090
                                    }]
                                }
                            ]
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-authpolicy-prometheus"
                    spec.forProvider.manifest = {
                        apiVersion = "security.istio.io/v1"
                        kind = "AuthorizationPolicy"
                        metadata.name = "exposure-prometheus"
                        spec = {
                            action = "CUSTOM"
                            provider.name = "monitoring-oauth2-proxy"
                            targetRefs = [{
                                group = ""
                                kind = "Service"
                                name = "exposure-prometheus"
                            }]
                        }
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "ObserveStack"
                    metadata.name = "observe"
                    status.exposure = {
                        domain = "observe.example.com"
                        extensionProviderName = "monitoring-oauth2-proxy"
                        cookieDomain = ".observe.example.com"
                        prometheus = {
                            enabled = True
                            url = "https://prometheus.observe.example.com/"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # exposure: grafana app-level OIDC composes its own Zitadel client,
    # writes generic_oauth Helm values into kube-prometheus-stack, mounts
    # the OIDC client Secret, and exposes via single-rule HTTPRoute with
    # NO AuthorizationPolicy.CUSTOM (Grafana enforces its own auth).
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "exposure-grafana-app-level-oidc-shape"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    namespace = "monitoring"
                    aws.region = "us-east-1"
                    auth = {
                        issuerURL = "https://auth.example.com"
                        awsSecretsManagerPath = "push/my-cluster/zitadel-credentials"
                        zitadelProjectId = "330000000000000001"
                    }
                    exposure = {
                        enabled = True
                        domain = "observe.example.com"
                        oauth2Proxy.cookieSecretRef.name = "observe-oauth2-proxy-cookie"
                        grafana = {
                            enabled = True
                            host = "grafana.observe.example.com"
                            allowedDomains = ["example.com"]
                            roleAttributePath = "contains(\"urn:zitadel:iam:org:project:roles\", \"observe-admin\") && \"Admin\" || \"Viewer\""
                        }
                    }
                }
            }
            assertResources = [
                # Dedicated Grafana OIDC client (separate from oauth2-proxy)
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-grafana-oidc-app"
                    spec.forProvider.manifest = {
                        apiVersion = "application.zitadel.m.crossplane.io/v1alpha1"
                        kind = "Oidc"
                        metadata.name = "monitoring-grafana"
                        spec = {
                            forProvider = {
                                projectId = "330000000000000001"
                                redirectUris = ["https://grafana.observe.example.com/login/generic_oauth"]
                                postLogoutRedirectUris = ["https://grafana.observe.example.com/"]
                            }
                            writeConnectionSecretToRef.name = "monitoring-grafana-oidc-client"
                            providerConfigRef.name = "zitadel-observe-stack"
                        }
                    }
                }
                # Sister Service for grafana (same waypoint labels as ext_authz components)
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-sister-svc-grafana"
                    spec.forProvider.manifest = {
                        apiVersion = "v1"
                        kind = "Service"
                        metadata.name = "exposure-grafana"
                        metadata.labels = {
                            "istio.io/use-waypoint" = "monitoring-waypoint"
                            "istio.io/ingress-use-waypoint" = "true"
                        }
                        spec.selector = {
                            "app.kubernetes.io/name" = "grafana"
                            "app.kubernetes.io/instance" = "kube-prometheus-stack"
                        }
                    }
                }
                # Single-rule HTTPRoute (no /oauth2/* detour — Grafana speaks OIDC itself)
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-exposure-httproute-grafana"
                    spec.forProvider.manifest = {
                        apiVersion = "gateway.networking.k8s.io/v1"
                        kind = "HTTPRoute"
                        metadata.name = "exposure-grafana"
                        spec.rules = [{
                            matches = [{ path = { type = "PathPrefix", value = "/" } }]
                            backendRefs = [{
                                name = "exposure-grafana"
                                namespace = "monitoring"
                                port = 80
                            }]
                        }]
                    }
                }
                # XR status surface (app_level branch populates oidcClientReady too)
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "ObserveStack"
                    metadata.name = "observe"
                    status.exposure.grafana = {
                        enabled = True
                        url = "https://grafana.observe.example.com/"
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # exposure: components default to disabled — no per-component resources
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "exposure-no-components-still-composes-bridge"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    namespace = "monitoring"
                    aws.region = "us-east-1"
                    auth = {
                        issuerURL = "https://auth.example.com"
                        awsSecretsManagerPath = "push/my-cluster/zitadel-credentials"
                        zitadelProjectId = "330000000000000001"
                    }
                    exposure = {
                        enabled = True
                        domain = "observe.example.com"
                        oauth2Proxy.cookieSecretRef.name = "observe-oauth2-proxy-cookie"
                    }
                }
            }
            assertResources = [
                # extensionProviderName defaults to <observe-ns>-oauth2-proxy
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "ObserveStack"
                    metadata.name = "observe"
                    status.exposure.extensionProviderName = "monitoring-oauth2-proxy"
                }
            ]
        }
    }
]

items = _items
