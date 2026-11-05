import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

items = [
    metav1alpha1.CompositionTest {
        "metadata" = {
            "name" = "goldilocks-builds-private-oauth-service-and-policy"
        }
        "spec" = {
            "compositionPath" = "apis/observestacks/composition.yaml"
            "xrdPath" = "apis/observestacks/definition.yaml"
            "timeoutSeconds" = 90
            "validate" = False
            "xr" = {
                "apiVersion" = "aws.hops.ops.com.ai/v1alpha1"
                "kind" = "ObserveStack"
                "metadata" = {
                    "name" = "observe"
                }
                "spec" = {
                    "clusterName" = "example"
                    "namespace" = "monitoring"
                    "aws" = {
                        "region" = "us-east-2"
                    }
                    "auth" = {
                        "issuerURL" = "https://auth.example.com"
                        "zitadelProjectId" = "123456"
                        "awsSecretsManagerPath" = "observe/oidc"
                        "secretStoreRef" = {
                            "name" = "aws"
                            "kind" = "ClusterSecretStore"
                        }
                    }
                    "exposure" = {
                        "enabled" = True
                        "domain" = "ops.example.com"
                        "gatewayRef" = {
                            "name" = "private"
                            "namespace" = "istio-ingress"
                            "sectionNames" = [
                                "https-monitoring"
                            ]
                        }
                        "routeAnnotations" = {
                            "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
                        }
                        "oauth2Proxy" = {
                            "cookieSecretRef" = {
                                "name" = "cookie"
                            }
                        }
                        "goldilocks" = {
                            "enabled" = True
                            "host" = "goldilocks.ops.example.com"
                        }
                    }
                }
            }
            "observedResources" = [
            ]
            "assertResources" = [
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-sister-svc-goldilocks"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "Service"
                                "metadata" = {
                                    "name" = "exposure-goldilocks"
                                    "namespace" = "monitoring"
                                    "labels" = {
                                        "istio.io/use-waypoint" = "monitoring-waypoint"
                                        "istio.io/ingress-use-waypoint" = "true"
                                    }
                                }
                                "spec" = {
                                    "type" = "ClusterIP"
                                    "selector" = {
                                        "app.kubernetes.io/name" = "goldilocks"
                                        "app.kubernetes.io/instance" = "goldilocks"
                                        "app.kubernetes.io/component" = "dashboard"
                                    }
                                    "ports" = [
                                        {
                                            "name" = "http"
                                            "port" = 80
                                            "targetPort" = "http"
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-authpolicy-goldilocks"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "AuthorizationPolicy"
                                "metadata" = {
                                    "name" = "exposure-goldilocks"
                                }
                                "spec" = {
                                    "targetRefs" = [
                                        {
                                            "group" = ""
                                            "kind" = "Service"
                                            "name" = "exposure-goldilocks"
                                        }
                                    ]
                                    "action" = "CUSTOM"
                                    "provider" = {
                                        "name" = "monitoring-oauth2-proxy"
                                    }
                                    "rules" = [
                                        {
                                            "to" = [
                                                {
                                                    "operation" = {
                                                        "notPaths" = [
                                                            "/oauth2/*"
                                                        ]
                                                    }
                                                }
                                            ]
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-oidc-app"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "Oidc"
                                "metadata" = {
                                    "name" = "monitoring-oauth2-proxy"
                                }
                                "spec" = {
                                    "forProvider" = {
                                        "redirectUris" = [
                                            "https://goldilocks.ops.example.com/oauth2/callback"
                                        ]
                                        "postLogoutRedirectUris" = [
                                            "https://goldilocks.ops.example.com/"
                                        ]
                                    }
                                    "writeConnectionSecretToRef" = {
                                        "name" = "monitoring-oauth2-proxy-oidc-client"
                                    }
                                }
                            }
                        }
                    }
                }
            ]
        }
    }
    metav1alpha1.CompositionTest {
        "metadata" = {
            "name" = "goldilocks-ready-route-has-all-deletion-dependencies"
        }
        "spec" = {
            "compositionPath" = "apis/observestacks/composition.yaml"
            "xrdPath" = "apis/observestacks/definition.yaml"
            "timeoutSeconds" = 90
            "validate" = False
            "xr" = {
                "apiVersion" = "aws.hops.ops.com.ai/v1alpha1"
                "kind" = "ObserveStack"
                "metadata" = {
                    "name" = "observe"
                }
                "spec" = {
                    "clusterName" = "example"
                    "namespace" = "monitoring"
                    "aws" = {
                        "region" = "us-east-2"
                    }
                    "auth" = {
                        "issuerURL" = "https://auth.example.com"
                        "zitadelProjectId" = "123456"
                        "awsSecretsManagerPath" = "observe/oidc"
                        "secretStoreRef" = {
                            "name" = "aws"
                            "kind" = "ClusterSecretStore"
                        }
                    }
                    "exposure" = {
                        "enabled" = True
                        "domain" = "ops.example.com"
                        "gatewayRef" = {
                            "name" = "private"
                            "namespace" = "istio-ingress"
                            "sectionNames" = [
                                "https-monitoring"
                            ]
                        }
                        "routeAnnotations" = {
                            "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
                        }
                        "oauth2Proxy" = {
                            "cookieSecretRef" = {
                                "name" = "cookie"
                            }
                        }
                        "goldilocks" = {
                            "enabled" = True
                            "host" = "goldilocks.ops.example.com"
                        }
                    }
                }
            }
            "observedResources" = [
                {
                    "apiVersion" = "helm.m.crossplane.io/v1beta1"
                    "kind" = "Release"
                    "metadata" = {
                        "name" = "goldilocks"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "goldilocks"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-sister-svc-goldilocks"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-sister-svc-goldilocks"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-authpolicy-goldilocks"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-authpolicy-goldilocks"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                        "atProvider" = {
                            "manifest" = {
                                "metadata" = {
                                    "uid" = "policy-uid"
                                }
                                "status" = {
                                    "conditions" = [
                                        {
                                            "type" = "WaypointAccepted"
                                            "status" = "True"
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-httproute-goldilocks"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-httproute-goldilocks"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-waypoint"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-waypoint"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-oauth2-proxy-deploy"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-oauth2-proxy-deploy"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-redis-sts"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-redis-sts"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-oidc-app"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-oidc-app"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-zitadel-credentials"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-zitadel-credentials"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-zitadel-providerconfig"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-zitadel-providerconfig"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
            ]
            "assertResources" = [
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-sister-svc-goldilocks"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "Service"
                                "metadata" = {
                                    "name" = "exposure-goldilocks"
                                    "namespace" = "monitoring"
                                    "labels" = {
                                        "istio.io/use-waypoint" = "monitoring-waypoint"
                                        "istio.io/ingress-use-waypoint" = "true"
                                    }
                                }
                                "spec" = {
                                    "type" = "ClusterIP"
                                    "selector" = {
                                        "app.kubernetes.io/name" = "goldilocks"
                                        "app.kubernetes.io/instance" = "goldilocks"
                                        "app.kubernetes.io/component" = "dashboard"
                                    }
                                    "ports" = [
                                        {
                                            "name" = "http"
                                            "port" = 80
                                            "targetPort" = "http"
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-authpolicy-goldilocks"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "AuthorizationPolicy"
                                "metadata" = {
                                    "name" = "exposure-goldilocks"
                                }
                                "spec" = {
                                    "targetRefs" = [
                                        {
                                            "group" = ""
                                            "kind" = "Service"
                                            "name" = "exposure-goldilocks"
                                        }
                                    ]
                                    "action" = "CUSTOM"
                                    "provider" = {
                                        "name" = "monitoring-oauth2-proxy"
                                    }
                                    "rules" = [
                                        {
                                            "to" = [
                                                {
                                                    "operation" = {
                                                        "notPaths" = [
                                                            "/oauth2/*"
                                                        ]
                                                    }
                                                }
                                            ]
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-httproute-goldilocks"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "HTTPRoute"
                                "metadata" = {
                                    "name" = "exposure-goldilocks"
                                    "annotations" = {
                                        "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
                                    }
                                }
                                "spec" = {
                                    "hostnames" = [
                                        "goldilocks.ops.example.com"
                                    ]
                                    "parentRefs" = [
                                        {
                                            "name" = "private"
                                            "namespace" = "istio-ingress"
                                            "sectionName" = "https-monitoring"
                                        }
                                    ]
                                    "rules" = [
                                        {
                                            "matches" = [
                                                {
                                                    "path" = {
                                                        "type" = "PathPrefix"
                                                        "value" = "/oauth2"
                                                    }
                                                }
                                            ]
                                            "backendRefs" = [
                                                {
                                                    "name" = "monitoring-oauth2-proxy"
                                                    "namespace" = "monitoring"
                                                    "port" = 4180
                                                }
                                            ]
                                        }
                                        {
                                            "matches" = [
                                                {
                                                    "path" = {
                                                        "type" = "PathPrefix"
                                                        "value" = "/"
                                                    }
                                                }
                                            ]
                                            "backendRefs" = [
                                                {
                                                    "name" = "exposure-goldilocks"
                                                    "namespace" = "monitoring"
                                                    "port" = 80
                                                }
                                            ]
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-oidc-app"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "Oidc"
                                "metadata" = {
                                    "name" = "monitoring-oauth2-proxy"
                                }
                                "spec" = {
                                    "forProvider" = {
                                        "redirectUris" = [
                                            "https://goldilocks.ops.example.com/oauth2/callback"
                                        ]
                                        "postLogoutRedirectUris" = [
                                            "https://goldilocks.ops.example.com/"
                                        ]
                                    }
                                    "writeConnectionSecretToRef" = {
                                        "name" = "monitoring-oauth2-proxy-oidc-client"
                                    }
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "protection.crossplane.io/v1beta1"
                    "kind" = "Usage"
                    "metadata" = {
                        "name" = "observe-delete-goldilocks-route-before-goldilocks"
                    }
                    "spec" = {
                        "replayDeletion" = True
                        "of" = {
                            "apiVersion" = "helm.m.crossplane.io/v1beta1"
                            "kind" = "Release"
                            "resourceRef" = {
                                "name" = "goldilocks"
                            }
                        }
                        "by" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-httproute-goldilocks"
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "protection.crossplane.io/v1beta1"
                    "kind" = "Usage"
                    "metadata" = {
                        "name" = "observe-delete-goldilocks-route-before-exposure-sister-svc-goldilocks"
                    }
                    "spec" = {
                        "replayDeletion" = True
                        "of" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-sister-svc-goldilocks"
                            }
                        }
                        "by" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-httproute-goldilocks"
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "protection.crossplane.io/v1beta1"
                    "kind" = "Usage"
                    "metadata" = {
                        "name" = "observe-delete-goldilocks-route-before-exposure-authpolicy-goldilocks"
                    }
                    "spec" = {
                        "replayDeletion" = True
                        "of" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-authpolicy-goldilocks"
                            }
                        }
                        "by" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-httproute-goldilocks"
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "protection.crossplane.io/v1beta1"
                    "kind" = "Usage"
                    "metadata" = {
                        "name" = "observe-delete-goldilocks-route-before-exposure-waypoint"
                    }
                    "spec" = {
                        "replayDeletion" = True
                        "of" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-waypoint"
                            }
                        }
                        "by" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-httproute-goldilocks"
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "protection.crossplane.io/v1beta1"
                    "kind" = "Usage"
                    "metadata" = {
                        "name" = "observe-delete-goldilocks-route-before-exposure-oauth2-proxy-deploy"
                    }
                    "spec" = {
                        "replayDeletion" = True
                        "of" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-oauth2-proxy-deploy"
                            }
                        }
                        "by" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-httproute-goldilocks"
                            }
                        }
                    }
                }
            ]
        }
    }
    metav1alpha1.CompositionTest {
        "metadata" = {
            "name" = "goldilocks-route-survives-policy-ready-flip"
        }
        "spec" = {
            "compositionPath" = "apis/observestacks/composition.yaml"
            "xrdPath" = "apis/observestacks/definition.yaml"
            "timeoutSeconds" = 90
            "validate" = False
            "xr" = {
                "apiVersion" = "aws.hops.ops.com.ai/v1alpha1"
                "kind" = "ObserveStack"
                "metadata" = {
                    "name" = "observe"
                }
                "spec" = {
                    "clusterName" = "example"
                    "namespace" = "monitoring"
                    "aws" = {
                        "region" = "us-east-2"
                    }
                    "auth" = {
                        "issuerURL" = "https://auth.example.com"
                        "zitadelProjectId" = "123456"
                        "awsSecretsManagerPath" = "observe/oidc"
                        "secretStoreRef" = {
                            "name" = "aws"
                            "kind" = "ClusterSecretStore"
                        }
                    }
                    "exposure" = {
                        "enabled" = True
                        "domain" = "ops.example.com"
                        "gatewayRef" = {
                            "name" = "private"
                            "namespace" = "istio-ingress"
                            "sectionNames" = [
                                "https-monitoring"
                            ]
                        }
                        "routeAnnotations" = {
                            "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
                        }
                        "oauth2Proxy" = {
                            "cookieSecretRef" = {
                                "name" = "cookie"
                            }
                        }
                        "goldilocks" = {
                            "enabled" = True
                            "host" = "goldilocks.ops.example.com"
                        }
                    }
                }
            }
            "observedResources" = [
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-authpolicy-goldilocks"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-authpolicy-goldilocks"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "False"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                        "atProvider" = {
                            "manifest" = {
                                "metadata" = {
                                    "uid" = "policy-uid"
                                }
                                "status" = {
                                    "conditions" = [
                                        {
                                            "type" = "WaypointAccepted"
                                            "status" = "True"
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
            ]
            "assertResources" = [
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-httproute-goldilocks"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "HTTPRoute"
                                "metadata" = {
                                    "name" = "exposure-goldilocks"
                                    "annotations" = {
                                        "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
                                    }
                                }
                                "spec" = {
                                    "hostnames" = [
                                        "goldilocks.ops.example.com"
                                    ]
                                    "parentRefs" = [
                                        {
                                            "name" = "private"
                                            "namespace" = "istio-ingress"
                                            "sectionName" = "https-monitoring"
                                        }
                                    ]
                                    "rules" = [
                                        {
                                            "matches" = [
                                                {
                                                    "path" = {
                                                        "type" = "PathPrefix"
                                                        "value" = "/oauth2"
                                                    }
                                                }
                                            ]
                                            "backendRefs" = [
                                                {
                                                    "name" = "monitoring-oauth2-proxy"
                                                    "namespace" = "monitoring"
                                                    "port" = 4180
                                                }
                                            ]
                                        }
                                        {
                                            "matches" = [
                                                {
                                                    "path" = {
                                                        "type" = "PathPrefix"
                                                        "value" = "/"
                                                    }
                                                }
                                            ]
                                            "backendRefs" = [
                                                {
                                                    "name" = "exposure-goldilocks"
                                                    "namespace" = "monitoring"
                                                    "port" = 80
                                                }
                                            ]
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-authpolicy-goldilocks"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "AuthorizationPolicy"
                                "metadata" = {
                                    "name" = "exposure-goldilocks"
                                }
                                "spec" = {
                                    "targetRefs" = [
                                        {
                                            "group" = ""
                                            "kind" = "Service"
                                            "name" = "exposure-goldilocks"
                                        }
                                    ]
                                    "action" = "CUSTOM"
                                    "provider" = {
                                        "name" = "monitoring-oauth2-proxy"
                                    }
                                    "rules" = [
                                        {
                                            "to" = [
                                                {
                                                    "operation" = {
                                                        "notPaths" = [
                                                            "/oauth2/*"
                                                        ]
                                                    }
                                                }
                                            ]
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
            ]
        }
    }
    metav1alpha1.CompositionTest {
        "metadata" = {
            "name" = "goldilocks-port-and-selector-overrides-keep-auth"
        }
        "spec" = {
            "compositionPath" = "apis/observestacks/composition.yaml"
            "xrdPath" = "apis/observestacks/definition.yaml"
            "timeoutSeconds" = 90
            "validate" = False
            "xr" = {
                "apiVersion" = "aws.hops.ops.com.ai/v1alpha1"
                "kind" = "ObserveStack"
                "metadata" = {
                    "name" = "observe"
                }
                "spec" = {
                    "clusterName" = "example"
                    "namespace" = "monitoring"
                    "aws" = {
                        "region" = "us-east-2"
                    }
                    "auth" = {
                        "issuerURL" = "https://auth.example.com"
                        "zitadelProjectId" = "123456"
                        "awsSecretsManagerPath" = "observe/oidc"
                        "secretStoreRef" = {
                            "name" = "aws"
                            "kind" = "ClusterSecretStore"
                        }
                    }
                    "exposure" = {
                        "enabled" = True
                        "domain" = "ops.example.com"
                        "gatewayRef" = {
                            "name" = "private"
                            "namespace" = "istio-ingress"
                            "sectionNames" = [
                                "https-monitoring"
                            ]
                        }
                        "routeAnnotations" = {
                            "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
                        }
                        "oauth2Proxy" = {
                            "cookieSecretRef" = {
                                "name" = "cookie"
                            }
                        }
                        "goldilocks" = {
                            "enabled" = True
                            "host" = "goldilocks.ops.example.com"
                            "servicePort" = 8081
                            "podSelector" = {
                                "app" = "custom-goldilocks"
                            }
                        }
                    }
                }
            }
            "observedResources" = [
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-authpolicy-goldilocks"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-authpolicy-goldilocks"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                        "atProvider" = {
                            "manifest" = {
                                "metadata" = {
                                    "uid" = "policy-uid"
                                }
                                "status" = {
                                    "conditions" = [
                                        {
                                            "type" = "WaypointAccepted"
                                            "status" = "True"
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
            ]
            "assertResources" = [
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-sister-svc-goldilocks"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "Service"
                                "metadata" = {
                                    "name" = "exposure-goldilocks"
                                    "namespace" = "monitoring"
                                    "labels" = {
                                        "istio.io/use-waypoint" = "monitoring-waypoint"
                                        "istio.io/ingress-use-waypoint" = "true"
                                    }
                                }
                                "spec" = {
                                    "type" = "ClusterIP"
                                    "selector" = {
                                        "app" = "custom-goldilocks"
                                    }
                                    "ports" = [
                                        {
                                            "name" = "http"
                                            "port" = 8081
                                            "targetPort" = "http"
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-httproute-goldilocks"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "HTTPRoute"
                                "metadata" = {
                                    "name" = "exposure-goldilocks"
                                    "annotations" = {
                                        "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
                                    }
                                }
                                "spec" = {
                                    "hostnames" = [
                                        "goldilocks.ops.example.com"
                                    ]
                                    "parentRefs" = [
                                        {
                                            "name" = "private"
                                            "namespace" = "istio-ingress"
                                            "sectionName" = "https-monitoring"
                                        }
                                    ]
                                    "rules" = [
                                        {
                                            "matches" = [
                                                {
                                                    "path" = {
                                                        "type" = "PathPrefix"
                                                        "value" = "/oauth2"
                                                    }
                                                }
                                            ]
                                            "backendRefs" = [
                                                {
                                                    "name" = "monitoring-oauth2-proxy"
                                                    "namespace" = "monitoring"
                                                    "port" = 4180
                                                }
                                            ]
                                        }
                                        {
                                            "matches" = [
                                                {
                                                    "path" = {
                                                        "type" = "PathPrefix"
                                                        "value" = "/"
                                                    }
                                                }
                                            ]
                                            "backendRefs" = [
                                                {
                                                    "name" = "exposure-goldilocks"
                                                    "namespace" = "monitoring"
                                                    "port" = 8081
                                                }
                                            ]
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-authpolicy-goldilocks"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "AuthorizationPolicy"
                                "metadata" = {
                                    "name" = "exposure-goldilocks"
                                }
                                "spec" = {
                                    "targetRefs" = [
                                        {
                                            "group" = ""
                                            "kind" = "Service"
                                            "name" = "exposure-goldilocks"
                                        }
                                    ]
                                    "action" = "CUSTOM"
                                    "provider" = {
                                        "name" = "monitoring-oauth2-proxy"
                                    }
                                    "rules" = [
                                        {
                                            "to" = [
                                                {
                                                    "operation" = {
                                                        "notPaths" = [
                                                            "/oauth2/*"
                                                        ]
                                                    }
                                                }
                                            ]
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
            ]
        }
    }
    metav1alpha1.CompositionTest {
        "metadata" = {
            "name" = "goldilocks-disabled-does-not-add-oauth-callback"
        }
        "spec" = {
            "compositionPath" = "apis/observestacks/composition.yaml"
            "xrdPath" = "apis/observestacks/definition.yaml"
            "timeoutSeconds" = 90
            "validate" = False
            "xr" = {
                "apiVersion" = "aws.hops.ops.com.ai/v1alpha1"
                "kind" = "ObserveStack"
                "metadata" = {
                    "name" = "observe"
                }
                "spec" = {
                    "clusterName" = "example"
                    "namespace" = "monitoring"
                    "aws" = {
                        "region" = "us-east-2"
                    }
                    "auth" = {
                        "issuerURL" = "https://auth.example.com"
                        "zitadelProjectId" = "123456"
                        "awsSecretsManagerPath" = "observe/oidc"
                        "secretStoreRef" = {
                            "name" = "aws"
                            "kind" = "ClusterSecretStore"
                        }
                    }
                    "exposure" = {
                        "enabled" = True
                        "domain" = "ops.example.com"
                        "gatewayRef" = {
                            "name" = "private"
                            "namespace" = "istio-ingress"
                            "sectionNames" = [
                                "https-monitoring"
                            ]
                        }
                        "routeAnnotations" = {
                            "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
                        }
                        "oauth2Proxy" = {
                            "cookieSecretRef" = {
                                "name" = "cookie"
                            }
                        }
                        "goldilocks" = {
                            "enabled" = False
                            "host" = "goldilocks.ops.example.com"
                        }
                        "prometheus" = {
                            "enabled" = True
                            "host" = "prometheus.ops.example.com"
                        }
                    }
                }
            }
            "observedResources" = [
            ]
            "assertResources" = [
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-oidc-app"
                    }
                    "spec" = {
                        "forProvider" = {
                            "manifest" = {
                                "kind" = "Oidc"
                                "metadata" = {
                                    "name" = "monitoring-oauth2-proxy"
                                }
                                "spec" = {
                                    "forProvider" = {
                                        "redirectUris" = [
                                            "https://prometheus.ops.example.com/oauth2/callback"
                                        ]
                                        "postLogoutRedirectUris" = [
                                            "https://prometheus.ops.example.com/"
                                        ]
                                    }
                                    "writeConnectionSecretToRef" = {
                                        "name" = "monitoring-oauth2-proxy-oidc-client"
                                    }
                                }
                            }
                        }
                    }
                }
            ]
        }
    }
    metav1alpha1.CompositionTest {
        "metadata" = {
            "name" = "goldilocks-disable-retains-route-deletion-ordering"
        }
        "spec" = {
            "compositionPath" = "apis/observestacks/composition.yaml"
            "xrdPath" = "apis/observestacks/definition.yaml"
            "timeoutSeconds" = 90
            "validate" = False
            "xr" = {
                "apiVersion" = "aws.hops.ops.com.ai/v1alpha1"
                "kind" = "ObserveStack"
                "metadata" = {
                    "name" = "observe"
                }
                "spec" = {
                    "clusterName" = "example"
                    "namespace" = "monitoring"
                    "aws" = {
                        "region" = "us-east-2"
                    }
                    "auth" = {
                        "issuerURL" = "https://auth.example.com"
                        "zitadelProjectId" = "123456"
                        "awsSecretsManagerPath" = "observe/oidc"
                        "secretStoreRef" = {
                            "name" = "aws"
                            "kind" = "ClusterSecretStore"
                        }
                    }
                    "exposure" = {
                        "enabled" = True
                        "domain" = "ops.example.com"
                        "gatewayRef" = {
                            "name" = "private"
                            "namespace" = "istio-ingress"
                            "sectionNames" = [
                                "https-monitoring"
                            ]
                        }
                        "routeAnnotations" = {
                            "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
                        }
                        "oauth2Proxy" = {
                            "cookieSecretRef" = {
                                "name" = "cookie"
                            }
                        }
                        "goldilocks" = {
                            "enabled" = False
                            "host" = "goldilocks.ops.example.com"
                        }
                    }
                }
            }
            "observedResources" = [
                {
                    "apiVersion" = "helm.m.crossplane.io/v1beta1"
                    "kind" = "Release"
                    "metadata" = {
                        "name" = "goldilocks"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "goldilocks"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-sister-svc-goldilocks"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-sister-svc-goldilocks"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-authpolicy-goldilocks"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-authpolicy-goldilocks"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                        "atProvider" = {
                            "manifest" = {
                                "metadata" = {
                                    "uid" = "policy-uid"
                                }
                                "status" = {
                                    "conditions" = [
                                        {
                                            "type" = "WaypointAccepted"
                                            "status" = "True"
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-httproute-goldilocks"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-httproute-goldilocks"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-waypoint"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-waypoint"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-oauth2-proxy-deploy"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-oauth2-proxy-deploy"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-redis-sts"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-redis-sts"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-oidc-app"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-oidc-app"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-zitadel-credentials"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-zitadel-credentials"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
                {
                    "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                    "kind" = "Object"
                    "metadata" = {
                        "name" = "observe-exposure-zitadel-providerconfig"
                        "annotations" = {
                            "crossplane.io/composition-resource-name" = "exposure-zitadel-providerconfig"
                        }
                    }
                    "status" = {
                        "conditions" = [
                            {
                                "type" = "Ready"
                                "status" = "True"
                            }
                            {
                                "type" = "Synced"
                                "status" = "True"
                            }
                        ]
                    }
                }
            ]
            "assertResources" = [
                {
                    "apiVersion" = "protection.crossplane.io/v1beta1"
                    "kind" = "Usage"
                    "metadata" = {
                        "name" = "observe-delete-goldilocks-route-before-goldilocks"
                    }
                    "spec" = {
                        "replayDeletion" = True
                        "of" = {
                            "apiVersion" = "helm.m.crossplane.io/v1beta1"
                            "kind" = "Release"
                            "resourceRef" = {
                                "name" = "goldilocks"
                            }
                        }
                        "by" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-httproute-goldilocks"
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "protection.crossplane.io/v1beta1"
                    "kind" = "Usage"
                    "metadata" = {
                        "name" = "observe-delete-goldilocks-route-before-exposure-sister-svc-goldilocks"
                    }
                    "spec" = {
                        "replayDeletion" = True
                        "of" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-sister-svc-goldilocks"
                            }
                        }
                        "by" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-httproute-goldilocks"
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "protection.crossplane.io/v1beta1"
                    "kind" = "Usage"
                    "metadata" = {
                        "name" = "observe-delete-goldilocks-route-before-exposure-authpolicy-goldilocks"
                    }
                    "spec" = {
                        "replayDeletion" = True
                        "of" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-authpolicy-goldilocks"
                            }
                        }
                        "by" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-httproute-goldilocks"
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "protection.crossplane.io/v1beta1"
                    "kind" = "Usage"
                    "metadata" = {
                        "name" = "observe-delete-goldilocks-route-before-exposure-waypoint"
                    }
                    "spec" = {
                        "replayDeletion" = True
                        "of" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-waypoint"
                            }
                        }
                        "by" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-httproute-goldilocks"
                            }
                        }
                    }
                }
                {
                    "apiVersion" = "protection.crossplane.io/v1beta1"
                    "kind" = "Usage"
                    "metadata" = {
                        "name" = "observe-delete-goldilocks-route-before-exposure-oauth2-proxy-deploy"
                    }
                    "spec" = {
                        "replayDeletion" = True
                        "of" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-oauth2-proxy-deploy"
                            }
                        }
                        "by" = {
                            "apiVersion" = "kubernetes.m.crossplane.io/v1alpha1"
                            "kind" = "Object"
                            "resourceRef" = {
                                "name" = "observe-exposure-httproute-goldilocks"
                            }
                        }
                    }
                }
            ]
        }
    }
]
