### What's changed in v1.0.0

* feat: drop prettyNames toggle and add NodePool size-floor defaults (by @patrickleet)

  BREAKING CHANGE: Standardize on the prettyNames=true behavior across all render
  templates: short component names (grafana, prometheus, etc.),
  fullnameOverride on the kube-prometheus-stack and k8s-monitoring
  helm releases, and no -pod-identity suffix on the opencost
  PodIdentity. Five render templates lose their conditionals.

  Default NodePool requirements now include eks.amazonaws.com/
  instance-memory > 7999 and instance-cpu > 1, so the dedicated
  observe pool never picks t.medium / c.large-style 4 GiB instances
  that OOM-kill the monitoring stack.

  Render tests updated to assert the new (pretty) names.

  BREAKING CHANGE: existing ObserveStacks that set spec.prettyNames
  will fail validation. Drop the field. In-cluster resource names
  change: kube-prometheus-stack-grafana -> grafana,
  observe-opencost-pod-identity -> observe-opencost, etc. Karpenter
  will mark existing sub-8GiB nodes in the observe pool as drifted.

* fix: relax probe defaults that flaked monitoring pods into crash loops (by @patrickleet)

  Charts ship 1s probe timeouts and 3-failure thresholds that cannot
  survive normal cluster load. Override per component via the existing
  kubePrometheusStack/k8sMonitoring values to stop the restart loops:

  - node-exporter: 5s timeout, 5 failure threshold
  - opencost exporter: 5s timeout, 5 failures, startupProbe with
    30-failure grace for cold start
  - alloy-operator: 5s timeout, 10 failures, initialDelaySeconds 15-30
  - prometheus container: 10s liveness timeout, 5s readiness, 10
    failures (via prometheusSpec.containers override since the operator
    doesn't expose probes directly)

* :  (by @patrickleet)

* fix: bump default NodePool memory floor to 16 GiB (by @patrickleet)

  The 8 GiB floor allowed Karpenter to pack prometheus + alloy-metrics +
  alloy-operator on a t2.large; node hit 98% memory, prometheus got
  SIGKILLed under pressure, opencost cascade-crashed (it ECONNREFUSEs
  on prometheus during startup and exits). 16 GiB gives prometheus the
  headroom the chart authors assume in production clusters.

  This is a backstop, not the durable fix — kube-prometheus-stack /
  k8s-monitoring chart components ship with empty resources blocks, so
  Karpenter places them blind. The real fix is per-component requests
  that match actual P95 usage. Tracked separately. See
  karpenter-resource-best-practices KB reference.

* feat: per-component resource defaults across the observe stack (by @patrickleet)

  Every workload the stack renders now ships with explicit requests +
  limits, picked deliberately per workload character (see
  references/karpenter-resource-best-practices §7):

  Memory: request == limit on every component (effective Guaranteed
  memory protection without setting CPU limits and triggering CFS
  throttling). Stateful workloads (prometheus 500m/4Gi, alloy-metrics
  100m/512Mi, loki single-binary 500m/2Gi, tempo 500m/1Gi, alertmanager
  50m/256Mi) get sized for steady-state P95.

  CPU: requests only, no limits. Burstable QoS so workloads can soak
  unused node capacity. Sized at chart-recommended values for
  small-to-medium clusters (<=50 nodes, <=500K series).

  DaemonSets (alloy-logs, alloy-receiver, node-exporter, loki-canary)
  get tiny defaults — they replicate per-node so frugality matters.

  Restart-cheap controllers (grafana, opencost, alloy-operator,
  grafana-operator, prometheus-operator, kube-state-metrics) get
  low requests + headroom-to-burst limits — the burst pattern is
  preserved where it actually helps.

  User escape hatches (kubePrometheusStack.values, k8sMonitoring.values,
  loki.values, tempo.values) still override these defaults.

  Implements [[tasks/per-component-resource-requests-limits-for-observe]]

* fix: bump kube-state-metrics and alloy-metrics memory to 1Gi (by @patrickleet)

  256Mi (KSM) and 512Mi (alloy-metrics) OOMKilled on a real cluster.
  Root cause:

  - kube-state-metrics caches state for every CRD's CRs. A vanilla
    cluster has ~30 CRDs; one running Crossplane providers has 800+
    (every AWS / Zitadel / upbound API). KSM scales linearly with
    total tracked-object count.
  - alloy-metrics holds discovered targets + remote-write WAL. The
    chart example value of 128Mi is documented as too low
    (k8s-monitoring-helm#541). 512Mi was still too tight once
    prometheus-operator-objects discovery enumerated all
    ServiceMonitors.

  Bump both to 1Gi request==limit so they survive a real cluster's
  object cardinality. Re-tune with VPA recommender once steady state
  is established per references/karpenter-resource-best-practices §5.

* fix: bump alloy-metrics memory to 2Gi (by @patrickleet)

  1Gi was still tight: the actual steady-state on a Crossplane-heavy
  cluster (865 CRDs being discovered via prometheus-operator-objects
  feature, plus accumulated WAL after several restarts) is ~1.7 GiB
  on pat-local. WAL replay after a restart spikes briefly above that,
  OOM-looping back at 1Gi.

  2Gi gives ~300Mi headroom over steady-state — re-tune with VPA
  recommender once the WAL backlog from prior restarts drains.

* feat: public zero-trust exposure surface (oauth2-proxy + Zitadel OIDC + ext_authz) (#41) (by @patrickleet)

  * feat: public exposure surface (oauth2-proxy + Zitadel OIDC + ext_authz)

  Adds spec.auth + spec.exposure to ObserveStack so internal dashboards
  (Prometheus, Alertmanager, OpenCost) can be reached from the public
  internet behind Zitadel OIDC. Composes everything the bridge needs:

  - ExternalSecret pulling the Zitadel iam-admin PAT from AWS Secrets
    Manager (matches AuthStack's consumer-providerconfig.yaml shape).
  - Namespaced Zitadel ProviderConfig.
  - Zitadel OIDC Application via provider-upjet-zitadel — writes the
    client_id + client_secret connection details into a K8s Secret.
  - Single-replica Redis StatefulSet for oauth2-proxy sessions.
  - Waypoint Gateway + per-component sister Services labeled
    istio.io/use-waypoint so AuthorizationPolicy.CUSTOM fires.
  - HTTPRoute per component (/oauth2/* -> oauth2-proxy, / -> sister svc).
  - AuthorizationPolicy.CUSTOM per component, provider name matches
    the IstioStack-registered extensionProvider.
  - Optional cert-manager Certificate when the platform wildcard at the
    Gateway doesn't cover spec.exposure.domain.

  Grafana app-level OIDC intentionally not included here — split into a
  sibling task for a smaller, focused follow-up.

  End-to-end verified on pat-local: composed OIDC client got
  client_id=373507418958665326 in Zitadel; curl through the waypointed
  sister Service returned "302 -> auth.ops.com.ai/oauth/v2/authorize?...";
  waypoint Envoy access log showed "302 UAEX ext_authz_denied".

  Implements [[tasks/observe-stack-public-exposure]]
  Pattern: [[specs/platform-public-exposure]]

  * fix: route Gateway-originated traffic through Waypoint + add HTTPS listener

  Two changes that close the gap between in-cluster ext_authz (which already
  worked) and external browser exposure (which 503'd):

  1. Add istio.io/ingress-use-waypoint=true on the sister Service.
     Without this label, Istio Gateway API gateways (kind: Gateway,
     gatewayClassName=istio) HBONE-tunnel direct to the destination pod
     and bypass the Waypoint, so AuthorizationPolicy.CUSTOM never fires
     for north-south traffic. The plain istio.io/use-waypoint label only
     redirects mesh-internal clients. See istio/istio#51214.

  2. spec.exposure.gatewayRef.sectionName -> sectionNames (list, defaults
     to [http, https-apex]). OAuth flows with cookie-secure=true redirect
     to HTTPS for the callback; the HTTPRoute now attaches to both
     listeners so the full flow completes without per-cluster manual
     parentRef wiring.

  End-to-end verified externally on pat-local:
  $ curl -D - https://prometheus.ops.com.ai/
  HTTP/2 302
  location: https://auth.ops.com.ai/oauth/v2/authorize?client_id=...
  $ # follow the chain -> Zitadel login UI 200 OK

  Implements [[tasks/observe-stack-public-exposure]]

  * feat: Grafana app-level OIDC via dedicated Zitadel client

  Adds spec.exposure.grafana with full app-level OIDC integration per
  feedback_app_level_oidc. Grafana speaks OIDC natively, so it sits
  DIRECTLY behind the Waypoint with no oauth2-proxy / ext_authz detour —
  auth happens inside Grafana itself.

  What composes when grafana.enabled=true:

  - A SECOND Zitadel Oidc MR (separate from the oauth2-proxy client)
    named <observe-ns>-grafana with redirectUris=[<host>/login/generic_oauth]
    and writeConnectionSecretToRef=<observe-ns>-grafana-oidc-client.

  - Grafana Helm values under kube-prometheus-stack:
    grafana.ini.auth.generic_oauth.{enabled, client_id ($__file{...}),
    client_secret ($__file{...}), auth_url, token_url, api_url,
    scopes, use_refresh_token, role_attribute_path, allowed_domains,
    ...}; auth.{login_maximum_lifetime_duration, token_rotation_interval_minutes};
    server.{domain, root_url}; extraSecretMounts mounting the OIDC
    client Secret at /etc/secrets/grafana-oidc so the secret stays off
    the env-var path.

  - Sister Service (with both istio.io/use-waypoint and ingress-use-waypoint
    labels per reference-ambient-ingress-use-waypoint) selecting the chart's
    Grafana pod.

  - Single-rule HTTPRoute (/ only — no /oauth2/* detour) attached to the
    platform Gateway on [http, https-apex].

  - NO AuthorizationPolicy.CUSTOM — Grafana enforces its own auth.

  Renderer split: introduces authMode discriminator per exposure component
  (ext_authz | app_level). Existing components keep ext_authz; grafana is
  the first app_level component. 470-httproutes branches on authMode for
  the /oauth2/* rule; 480-auth-policies skips app_level entries entirely.

  Status surface: status.exposure.grafana.{enabled, url, ready,
  oidcClientReady}. ready computed from kube-prometheus-stack readiness
  + Zitadel OIDC App MR readiness + Waypoint readiness.

  Tests: new "exposure-grafana-app-level-oidc-shape" KCL test asserts the
  2nd Oidc MR, sister Service labels, single-rule HTTPRoute backendRef,
  and the ABSENCE of an AuthorizationPolicy for Grafana. All 31 tests
  pass.

  Defaults follow specs/platform-public-exposure decision #7:
  use_refresh_token=true, login_maximum_lifetime_duration=8h,
  token_rotation_interval_minutes=10. Zitadel-side revocation propagates
  within ~10min.

  Implements [[tasks/observe-stack-grafana-oidc]]
  Pattern: [[specs/platform-public-exposure]]


See full diff: [v0.20.0...v1.0.0](https://github.com/hops-ops/aws-observe-stack/compare/v0.20.0...v1.0.0)
