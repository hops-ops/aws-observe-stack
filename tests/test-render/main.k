import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# Unit tests for stacks.aws Observe XRD
# ==============================================================================

_items = [
    # ==========================================================================
    # Test 1: Minimal input renders Observe and PodIdentity
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-observe-and-pod-identity"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
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
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec.clusterName = "my-cluster"
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-pod-identity"
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
    # Test 2: Custom namespace propagates to both resources
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-namespace-propagates"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
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
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec.namespace = "observability"
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-pod-identity"
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
    # Test 3: Observe passthrough fields forwarded correctly
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "observe-passthrough-fields"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    k8sMonitoring = {
                        values = {
                            opencost = {
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
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec.k8sMonitoring = {
                        values = {
                            opencost = {
                                enabled = True
                            }
                        }
                    }
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
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
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
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec = {
                        helmProviderConfigRef = {
                            name = "custom-helm"
                            kind = "ClusterProviderConfig"
                        }
                        kubernetesProviderConfigRef = {
                            name = "custom-k8s"
                            kind = "ProviderConfig"
                        }
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-pod-identity"
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
    # Test 5: Usage renders when both resources are ready
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "usage-renders-when-both-ready"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
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
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata = {
                        name = "observe"
                        annotations = {"crossplane.io/composition-resource-name" = "observe"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata = {
                        name = "observe-pod-identity"
                        annotations = {"crossplane.io/composition-resource-name" = "pod-identity"}
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
                    metadata.name = "observe-delete-observe-before-pod-identity"
                    spec = {
                        of = {
                            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                            kind = "PodIdentity"
                            resourceRef.name = "observe-pod-identity"
                        }
                        by = {
                            apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                            kind = "Observe"
                            resourceRef.name = "observe"
                        }
                        replayDeletion = True
                    }
                }
            ]
        }
    }
]

items = _items
