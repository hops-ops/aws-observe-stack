### What's changed in v0.12.0

* feat: flatten + goldilocks + vpa (#18) (by @patrickleet)

  * **New Features**
    * Add optional VPA and Goldilocks components and expose per-component configuration (name, namespace, values)
    * Deploy monitoring components as individual Helm releases (Prometheus stack, Loki, Tempo, k8s-monitoring, Grafana operator, VPA, Goldilocks)
    * Auto-configured Grafana instance with Prometheus/Loki/Tempo datasources and two OpenCost dashboards; enforced deletion ordering between operator, instance, and datasources

  * **Chores**
    * Update project metadata and dependency declarations

  * **Tests**
    * Expanded render tests to validate Helm releases, values/ storage modes (PVC vs S3), provider refs, readiness gating, datasources and dashboards


See full diff: [v0.11.0...v0.12.0](https://github.com/hops-ops/aws-observe-stack/compare/v0.11.0...v0.12.0)
