### What's changed in v0.17.0

* feat: open cost spot feed + optional metrics-server (#34) (by @patrickleet)

  * **New Features**
    * Metrics Server support with configurable Helm values and optional deployment.
    * Spot Feed support to enable OpenCost spot pricing (bucket, region, account, optional prefix); when enabled OpenCost is configured and appropriate S3 read permissions are granted.

  * **Examples**
    * Added example manifests demonstrating Metrics Server and Spot Feed configurations.

  * **Documentation**
    * Added Spot Instance Pricing section describing setup and effects.
  <!-- end of auto-generated comment: release notes by coderabbit.ai -->


See full diff: [v0.16.1...v0.17.0](https://github.com/hops-ops/aws-observe-stack/compare/v0.16.1...v0.17.0)
