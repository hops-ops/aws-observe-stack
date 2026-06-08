### What's changed in v2.0.0

* feat: tune observe scheduling and HA mode, s3 loki/tempo (#44) (by @patrickleet)

  BREAKING CHANGE: * fix: tune observe nodepool and resources - more aggressive consolidation by default

  * feat: add observe HA mode

  Implements scoped easy HA mode for ObserveStack with opt-in replica defaults, PDBs, and topology spread where supported. Loki and Tempo stay single-replica on PVC and only scale when storage is already S3.\n\nCloses [[tasks/observe-ha-mode]].\n\nTests:\n- make test\n- make render:nodepool\n- make validate:nodepool\n- make validate:all\n- local colima/pat-local validation

  * feat: harden observe s3 storage readiness

  * fix: address observe review feedback

  * fix: keep grafana single-replica in observe ha

  * feat: back grafana ha with psqlcluster

  * fix: support grafana oauth admin mapping

  * fix: align loki ha replication factor

  * fix: harden grafana ha activation


See full diff: [v1.2.0...v2.0.0](https://github.com/hops-ops/aws-observe-stack/compare/v1.2.0...v2.0.0)
