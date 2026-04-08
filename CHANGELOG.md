### What's changed in v0.16.0

* feat: pretty names (#33) (by @patrickleet)

  * **New Features**
    * Added a `prettyNames` option to ObserveStack (default: false). When enabled, it produces simplified, canonical names for Grafana objects, datasources, dashboards, unified Grafana/Prometheus service names and Helm fullname overrides, and shortens PodIdentity names via a configurable suffix. Defaults to false for backwards compatibility. Will be default in v1.

  * **Tests**
    * Added render and end-to-end tests validating naming behavior with `prettyNames` enabled and disabled.


See full diff: [v0.15.0...v0.16.0](https://github.com/hops-ops/aws-observe-stack/compare/v0.15.0...v0.16.0)
