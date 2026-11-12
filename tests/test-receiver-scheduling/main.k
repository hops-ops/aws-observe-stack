import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

# Keep omitted controller.type compatible with the chart's DaemonSet default.
# Centralized receivers must respect disruption and pressure taints; when a
# dedicated pool exists they need only that pool's workload toleration.
_types = ["default", "daemonset", "deployment", "statefulset"]
_overrides = ["none", "custom", "empty"]
items = [
    metav1alpha1.CompositionTest {
        metadata.name = "receiver-" + controllerType + "-pool-" + ("on" if pool else "off") + "-override-" + override
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
                    nodePool.enabled = pool
                    k8sMonitoring.values = {"alloy-receiver" = {controller = {
                        if controllerType != "default":
                            type = controllerType
                        if override != "none":
                            nodeSelector = {"custom-pool" = "receiver"}
                            tolerations = [{key = "custom-pool", operator = "Equal", value = "receiver", effect = "NoSchedule"}] if override == "custom" else []
                    }}}
                }
            }
            assertResources = [{
                apiVersion = "helm.m.crossplane.io/v1beta1"
                kind = "Release"
                metadata.name = "k8s-monitoring"
                spec.forProvider.values = {
                    "alloy-receiver" = {
                        enabled = True
                        controller = {
                            if controllerType != "default":
                                type = controllerType
                            if override != "none":
                                nodeSelector = {"custom-pool" = "receiver"}
                                tolerations = [{key = "custom-pool", operator = "Equal", value = "receiver", effect = "NoSchedule"}] if override == "custom" else []
                            elif controllerType in ["default", "daemonset"]:
                                tolerations = [{operator = "Exists"}]
                            elif pool:
                                nodeSelector = {"workload-type" = "observe"}
                                tolerations = [{key = "observe", value = "true", effect = "NoSchedule"}]
                            else:
                                tolerations = []
                        }
                    }
                    # Receiver policy must not change node-local log collection.
                    "alloy-logs" = {controller.tolerations = [{operator = "Exists"}]}
                }
            }]
        }
    }
    for controllerType in _types
    for pool in [False, True]
    for override in _overrides
]
