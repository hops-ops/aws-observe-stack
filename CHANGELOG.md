### What's changed in v2.17.0

* chore(deps): update unbounded-tech/workflow-vnext-tag action to v1.22.4 (#122) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* feat: support route annotations and pinned component charts (#123) (by @patrickleet)

  Add optional exposure HTTPRoute annotations and component chart version overrides while retaining packaged defaults and resource identities. Cover all four routes and seven chart selections in render tests; use non-default selections for every override assertion.

  Verified hosted schema checks, 37 KCL unit tests, AWS E2E and cleanup, and package publication before merge.

  Refs: [[tasks/observe-route-annotations]], [[tasks/observe-chart-version-overrides]].


See full diff: [v2.16.0...v2.17.0](https://github.com/hops-ops/aws-observe-stack/compare/v2.16.0...v2.17.0)
