# e2etest-observe - aws ObserveStack E2E Test
# ================================================
# Tests deployment of the ObserveStack with AWS Pod Identity for OpenCost billing access.
#
# This test creates:
# 1. An AutoEKSCluster using subnet IDs from the persistent hops-test network
# 2. An aws ObserveStack that composes:
#    - hops.ops.com.ai/ObserveStack (base observability stack)
#    - aws.hops.ops.com.ai/PodIdentity (IAM role + Pod Identity for OpenCost)
#
# Uses persistent network infrastructure from aws-network e2e test (hops-test)
# to speed up test execution by avoiding network creation/deletion.
#
# Prerequisites:
# 1. Create secrets/aws-creds file with AWS credentials in INI format:
#    [default]
#    aws_access_key_id = AKIA...
#    aws_secret_access_key = ...
#
# 2. Ensure the persistent hops-test network exists (from aws-network e2e test)
#
# 3. Run: make e2e
import base64
import file
import datetime
import math
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.ai.com.ops.hops.aws.v1alpha1 as awsv1alpha1

# Read AWS credentials from local file (gitignored)
_creds = file.read("secrets/aws-creds")
_base64_creds = base64.encode(_creds)
# =============================================================================
# Test Configuration
# =============================================================================
_now = str(int(math.floor(datetime.ticks())))
_test_name = "e2e-obs-" + _now
_namespace = "default"
_region = "us-east-2"
# CI test account
_account_id = "034489662075"
_admin_role_arn = "arn:aws:iam::034489662075:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdminAccess_e8d960044a7864f6"
# =============================================================================
# Persistent Network Infrastructure (from aws-network e2e test - hops-test)
# =============================================================================
# Private subnet IDs for the EKS cluster - these are already created and orphaned
_private_subnet_ids = [
    # private-a
    "subnet-0ba2f584c25e9435d"
    # private-b
    "subnet-02e4d512f8859e684"
]

_items = [
    metav1alpha1.E2ETest {
        metadata.name = "observe"
        spec = {
            crossplane = {
                autoUpgrade.channel = "Rapid"
            }
            defaultConditions = ["Ready"]
            # 90 minutes for EKS cluster creation
            timeoutSeconds = 5400
            # 30 minutes for cleanup
            cleanupTimeoutSeconds = 1800
            skipDelete = False
            # initResources: Install infrastructure Configuration packages
            # Note: observe-stack and opencost-pod-identity are auto-installed as dependencies
            initResources = [
                # aws-auto-eks-cluster Configuration package (provides AutoEKSCluster XRD)
                {
                    apiVersion = "pkg.crossplane.io/v1"
                    kind = "Configuration"
                    metadata = {
                        name = "aws-auto-eks-cluster"
                    }
                    spec = {
                        package = "ghcr.io/hops-ops/aws-auto-eks-cluster:v0.7.0"
                    }
                }
            ]
            # extraResources: Credentials and ProviderConfigs (not deleted during cleanup)
            extraResources = [
                # AWS credentials secret
                {
                    apiVersion = "v1"
                    kind = "Secret"
                    metadata = {
                        name = "aws-creds"
                        namespace = _namespace
                    }
                    data = {
                        creds = _base64_creds
                    }
                }
                # AWS ProviderConfig using Secret credentials
                {
                    apiVersion = "aws.m.upbound.io/v1beta1"
                    kind = "ProviderConfig"
                    metadata = {
                        name = "default"
                        namespace = _namespace
                    }
                    spec = {
                        credentials = {
                            source = "Secret"
                            secretRef = {
                                namespace = _namespace
                                name = "aws-creds"
                                key = "creds"
                            }
                        }
                    }
                }
                # Kubernetes ProviderConfig for in-cluster access
                {
                    apiVersion: "kubernetes.m.crossplane.io/v1alpha1"
                    kind: "ProviderConfig"
                    metadata: {
                        name: "default"
                        namespace: "default"
                    }
                    spec: {
                        credentials: {
                            source: "InjectedIdentity"
                        }
                    }
                }
                # DeploymentRuntimeConfig for Kubernetes provider with known SA name
                {
                    apiVersion: "pkg.crossplane.io/v1beta1"
                    kind: "DeploymentRuntimeConfig"
                    metadata: {
                        name: "crossplane-contrib-provider-kubernetes"
                    }
                    spec: {
                        serviceAccountTemplate: {
                            metadata: {
                                name: "crossplane-contrib-provider-kubernetes"
                            }
                        }
                    }
                }
                # ServiceAccount for Kubernetes provider
                {
                    apiVersion: "v1"
                    kind: "ServiceAccount"
                    metadata: {
                        name: "crossplane-contrib-provider-kubernetes"
                        namespace: "crossplane-system"
                    }
                }
                # ClusterRoleBinding granting cluster-admin to the K8s provider SA
                {
                    apiVersion: "rbac.authorization.k8s.io/v1"
                    kind: "ClusterRoleBinding"
                    metadata: {
                        name: "crossplane-contrib-provider-kubernetes-admin"
                    }
                    roleRef: {
                        apiGroup: "rbac.authorization.k8s.io"
                        kind: "ClusterRole"
                        name: "cluster-admin"
                    }
                    subjects: [
                        {
                            kind: "ServiceAccount"
                            name: "crossplane-contrib-provider-kubernetes"
                            namespace: "crossplane-system"
                        }
                    ]
                }
                # Provider with runtimeConfigRef to use our DeploymentRuntimeConfig
                {
                    apiVersion: "pkg.crossplane.io/v1"
                    kind: "Provider"
                    metadata: {
                        name: "crossplane-contrib-provider-kubernetes"
                    }
                    spec: {
                        package: "xpkg.crossplane.io/crossplane-contrib/provider-kubernetes:v1.2.0"
                        runtimeConfigRef: {
                            name: "crossplane-contrib-provider-kubernetes"
                        }
                    }
                }
                # EKS Cluster
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "AutoEKSCluster"
                    metadata = {
                        name = _test_name
                        namespace = _namespace
                    }
                    spec = {
                        adminRoleArn = _admin_role_arn
                        clusterName = _test_name
                        region = _region
                        accountId = _account_id
                        version = "1.35"
                        subnetIds = _private_subnet_ids
                        providerConfigRef = {
                            name = "default"
                            kind = "ProviderConfig"
                        }
                        kubernetesProviderConfigRef = {
                            name = "default"
                            kind = "ProviderConfig"
                        }
                        tags = {
                            "e2etest" = "true"
                            "test-run" = _now
                            "repo": "https://github.com/hops-ops/aws-observe-stack"
                        }
                        publicAccess = True
                        nodeConfig = {
                            enabled = True
                        }
                        oidc = {
                            enabled = False
                        }
                    }
                }
            ]
            # manifests: All XRs that need cleanup (AutoEKSCluster, Observe)
            # Note: Uses persistent hops-test network - no Network manifest needed
            manifests = [
                # ObserveStack
                awsv1alpha1.ObserveStack {
                    metadata.name = "observe"
                    metadata.namespace = _namespace
                    spec = {
                        clusterName = _test_name
                        aws = {
                            region = "us-east-2"
                        }
                        loki = {
                            storage = {
                                type = "pvc"
                                size = "10Gi"
                            }
                        }
                        tempo = {
                            storage = {
                                type = "pvc"
                                size = "10Gi"
                            }
                        }
                    }
                }
            ]
        }
    }
]

items = _items
