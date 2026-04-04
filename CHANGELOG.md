### What's changed in v0.15.0

* feat: optional separate node pool for observe workloads (#32)

  * **New Features**
    * Optional spec.nodePool to create a dedicated NodePool for observe workloads; non-daemonset components can be scheduled there via nodeSelector/tolerations while daemonsets remain on all nodes.

  * **Documentation**
    * Added "Dedicated NodePool" section, expanded resource breakdown, and included an example manifest demonstrating enablement.

  * **Chores**
    * Automation updated so the new example is included in render/validate workflows and build rules adjusted to include it.

  * **Tests**
    * Added render and e2e tests covering enabled and disabled NodePool scenarios.

  Closes #25


See full diff: [v0.14.2...v0.15.0](https://github.com/hops-ops/aws-observe-stack/compare/v0.14.2...v0.15.0)
