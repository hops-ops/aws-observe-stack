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
                    metadata.name = "observe-opencost-pod-identity"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-1"
                        serviceAccount = {
                            name = "k8s-monitoring-opencost"
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
                    metadata.name = "observe-opencost-pod-identity"
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
                    metadata.name = "observe-opencost-pod-identity"
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
                        name = "observe-opencost-pod-identity"
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
                            resourceRef.name = "my-cluster-observe-opencost-pod-identity"
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
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-loki-pod-identity"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-1"
                        serviceAccount = {
                            name = "loki"
                            namespace = "monitoring"
                        }
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
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-tempo-pod-identity"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-west-2"
                        serviceAccount = {
                            name = "tempo"
                            namespace = "monitoring"
                        }
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
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata = {
                        name = "observe-loki-pod-identity"
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
                            resourceRef.name = "my-cluster-observe-loki-pod-identity"
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
                        metadata.name = "observe-grafana"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-datasource-prometheus"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDatasource"
                        metadata.name = "observe-prometheus"
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
    # Test 12b: prettyNames shortens target-cluster Grafana object names
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "grafana-target-object-names-pretty-when-enabled"
        spec = {
            compositionPath = "apis/observestacks/composition.yaml"
            xrdPath = "apis/observestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "ObserveStack"
                metadata.name = "pat-local"
                spec = {
                    clusterName = "my-cluster"
                    prettyNames = True
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
                        name = "pat-local-grafana-instance"
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
                    metadata.name = "pat-local-grafana-instance"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "Grafana"
                        metadata.name = "grafana"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "pat-local-datasource-prometheus"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDatasource"
                        metadata.name = "prometheus"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "pat-local-datasource-loki"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDatasource"
                        metadata.name = "loki"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "pat-local-datasource-tempo"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDatasource"
                        metadata.name = "tempo"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "pat-local-dashboard-opencost-overview"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDashboard"
                        metadata.name = "opencost-overview"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "pat-local-dashboard-opencost-namespace"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDashboard"
                        metadata.name = "opencost-namespace"
                    }
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
                        {name = "prometheus", type = "prometheus", url = "http://kube-prometheus-stack-prometheus.monitoring:9090/api/v1/write"}
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
                                "prometheus-address" = "http://kube-prometheus-stack-prometheus.monitoring.svc:9090"
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
                        "alloy-metrics" = {enabled = True}
                        "alloy-receiver" = {enabled = True}
                        "alloy-singleton" = {enabled = True}
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
                        spec.template.spec.taints = [
                            {key = "observe", value = "true", effect = "NoSchedule"}
                        ]
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
    # Test: prettyNames changes PodIdentity names and Grafana fullnameOverride
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "pretty-names-enabled"
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
                    prettyNames = True
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-opencost"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-1"
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kube-prometheus-stack"
                    spec.forProvider.values = {
                        cleanPrometheusOperatorObjectNames = True
                        fullnameOverride = "observe"
                        alertmanager = {
                            alertmanagerSpec = {
                                fullnameOverride = "alertmanager"
                            }
                        }
                        grafana = {
                            fullnameOverride = "grafana"
                        }
                        "kube-state-metrics" = {
                            fullnameOverride = "kube-state-metrics"
                        }
                        nodeExporter = {
                            enabled = False
                            fullnameOverride = "node-exporter"
                        }
                        prometheus = {
                            prometheusSpec = {
                                fullnameOverride = "prometheus"
                            }
                        }
                        prometheusOperator = {
                            enabled = True
                            fullnameOverride = "prometheus-operator"
                        }
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.values = {
                        "alloy-logs" = {
                            enabled = True
                            fullnameOverride = "alloy-logs"
                        }
                        "alloy-metrics" = {
                            enabled = True
                            fullnameOverride = "alloy-metrics"
                        }
                        "alloy-operator" = {
                            fullnameOverride = "alloy-operator"
                        }
                        "alloy-receiver" = {
                            enabled = True
                            fullnameOverride = "alloy-receiver"
                        }
                        "alloy-singleton" = {
                            enabled = True
                            fullnameOverride = "alloy-singleton"
                        }
                        clusterMetrics = {
                            opencost = {
                                enabled = True
                                fullnameOverride = "opencost"
                            }
                            "node-exporter" = {
                                enabled = True
                                fullnameOverride = "node-exporter"
                            }
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test: prettyNames false preserves legacy names
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "pretty-names-disabled-preserves-legacy"
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
                    prettyNames = False
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
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-opencost-pod-identity"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-1"
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "kube-prometheus-stack"
                    spec.forProvider.values = {
                        cleanPrometheusOperatorObjectNames = False
                        fullnameOverride = ""
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "k8s-monitoring"
                    spec.forProvider.values = {
                        destinations = [
                            {
                                name = "prometheus"
                                type = "prometheus"
                                url = "http://kube-prometheus-stack-prometheus.monitoring:9090/api/v1/write"
                            }
                            {
                                name = "loki"
                                type = "loki"
                                url = "http://loki-gateway.monitoring:80/loki/api/v1/push"
                            }
                            {
                                name = "tempo"
                                type = "otlp"
                                protocol = "grpc"
                                url = "http://tempo.monitoring:4317"
                            }
                        ]
                        clusterMetrics = {
                            opencost = {
                                opencost = {
                                    prometheus = {
                                        external = {
                                            url = "http://kube-prometheus-stack-prometheus.monitoring:9090"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-grafana-instance"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "Grafana"
                        metadata.name = "observe-grafana"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-datasource-prometheus"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDatasource"
                        metadata.name = "observe-prometheus"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-datasource-loki"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDatasource"
                        metadata.name = "observe-loki"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-datasource-tempo"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDatasource"
                        metadata.name = "observe-tempo"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-dashboard-opencost-overview"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDashboard"
                        metadata.name = "observe-opencost-overview"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "observe-dashboard-opencost-namespace"
                    spec.forProvider.manifest = {
                        apiVersion = "grafana.integreatly.org/v1beta1"
                        kind = "GrafanaDashboard"
                        metadata.name = "observe-opencost-namespace"
                    }
                }
            ]
        }
    }
]

items = _items
