alertmanager:
  affinity: {}
  args: []
  command: []
  configuration: |
    receivers:
      - name: default-receiver
    route:
      group_wait: 10s
      group_interval: 5m
      receiver: default-receiver
      repeat_interval: 3h
  containerPorts:
    cluster: 9094
    http: 9093
  containerSecurityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    enabled: true
    privileged: false
    readOnlyRootFilesystem: false
    runAsNonRoot: true
    runAsUser: 1001
    seLinuxOptions: {}
    seccompProfile:
      type: RuntimeDefault
  customLivenessProbe: {}
  customReadinessProbe: {}
  customStartupProbe: {}
  enabled: true
  existingConfigmap: ""
  existingConfigmapKey: ""
  extraArgs: []
  extraEnvVars: []
  extraEnvVarsCM: ""
  extraEnvVarsSecret: ""
  extraVolumeMounts: []
  extraVolumes: []
  hostAliases: []
  image:
    digest: ""
    pullPolicy: IfNotPresent
    pullSecrets: []
    registry: docker.io
    repository: bitnami/alertmanager
    tag: 0.26.0-debian-11-r47
  ingress:
    annotations: {}
    enabled: false
    extraHosts: []
    extraPaths: []
    extraRules: []
    extraTls: []
    hostname: alertmanager.prometheus.local
    ingressClassName: ""
    path: /
    pathType: ImplementationSpecific
    secrets: []
    selfSigned: false
    tls: false
  initContainers: []
  lifecycleHooks: {}
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 5
    periodSeconds: 20
    successThreshold: 1
    timeoutSeconds: 3
  nodeAffinityPreset:
    key: ""
    type: ""
    values: []
  nodeSelector: {}
  pdb:
    create: false
    maxUnavailable: ""
    minAvailable: 1
  persistence:
    accessModes:
    - ReadWriteOnce
    annotations: {}
    enabled: false
    mountPath: /bitnami/alertmanager/data
    selector: {}
    size: 8Gi
    storageClass: ""
    subPath: ""
  podAffinityPreset: ""
  podAnnotations: {}
  podAntiAffinityPreset: soft
  podLabels: {}
  podManagementPolicy: OrderedReady
  podSecurityContext:
    enabled: true
    fsGroup: 1001
    fsGroupChangePolicy: Always
    supplementalGroups: []
    sysctls: []
  priorityClassName: ""
  readinessProbe:
    enabled: true
    failureThreshold: 5
    initialDelaySeconds: 5
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 2
  replicaCount: 1
  resources:
    limits: {}
    requests: {}
  schedulerName: ""
  service:
    annotations: {}
    clusterIP: ""
    externalTrafficPolicy: Cluster
    extraPorts: []
    loadBalancerClass: ""
    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    nodePorts:
      http: ""
    ports:
      cluster: 9094
      http: 80
    sessionAffinity: None
    sessionAffinityConfig: {}
    type: LoadBalancer
  serviceAccount:
    annotations: {}
    automountServiceAccountToken: false
    create: true
    name: ""
  sidecars: []
  startupProbe:
    enabled: false
    failureThreshold: 10
    initialDelaySeconds: 2
    periodSeconds: 5
    successThreshold: 1
    timeoutSeconds: 2
  terminationGracePeriodSeconds: ""
  tolerations: []
  topologySpreadConstraints: []
  updateStrategy:
    type: RollingUpdate
clusterDomain: cluster.local
common:
  exampleValue: common-chart
  global:
    imagePullSecrets: []
    imageRegistry: ""
    storageClass: ""
commonAnnotations: {}
commonLabels: {}
diagnosticMode:
  args:
  - infinity
  command:
  - sleep
  enabled: false
extraDeploy: []
fullnameOverride: ""
global:
  imagePullSecrets: []
  imageRegistry: ""
  storageClass: ""
ingress:
  apiVersion: ""
kubeVersion: ""
nameOverride: ""
namespaceOverride: ""
server:
  affinity: {}
  alertingEndpoints: []
  alertingRules: {}
  args: []
  command: []
  configuration: |
    global:
      {{- if .Values.server.scrapeInterval }}
      scrape_interval: {{ .Values.server.scrapeInterval }}
      {{- end }}
      {{- if .Values.server.scrapeTimeout }}
      scrape_timeout: {{ .Values.server.scrapeTimeout }}
      {{- end }}
      {{- if .Values.server.evaluationInterval }}
      evaluation_interval: {{ .Values.server.evaluationInterval }}
      {{- end }}
      external_labels:
        monitor: {{ template "common.names.fullname" . }}
        {{- if .Values.server.externalLabels }}
        {{- include "common.tplvalues.render" (dict "value" .Values.server.externalLabels "context" $) | nindent 4 }}
        {{- end }}
    {{- if .Values.server.remoteWrite }}
    remote_write: {{- include "common.tplvalues.render" (dict "value" .Values.server.remoteWrite "context" $) | nindent 4 }}
    {{- end }}
    scrape_configs:
      - job_name: prometheus
      {{- include "prometheus.scrape_config" (dict "component" "server" "context" $) | nindent 4 }}
    {{- if .Values.alertmanager.enabled }}
      - job_name: alertmanager
        {{- include "prometheus.scrape_config" (dict "component" "alertmanager" "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.server.extraScrapeConfigs}}
    {{- include "common.tplvalues.render" (dict "value" .Values.server.extraScrapeConfigs "context" $) | nindent 2 }}
    {{- end }}
    {{- if or .Values.alertmanager.enabled .Values.server.alertingEndpoints}}
    alerting:
      alertmanagers:
        {{- if .Values.server.alertingEndpoints }}
        {{- include "common.tplvalues.render" (dict "value" .Values.server.alertingEndpoints "context" $) | nindent 4 }}
        {{- end }}
        - scheme: HTTP
          static_configs:
            - targets: [ "{{ printf "%s.%s.svc.%s:%d" (include "prometheus.alertmanager.fullname" .) (include "common.names.namespace" .) .Values.clusterDomain (int .Values.alertmanager.service.ports.http) }}" ]
    rule_files:
      - rules.yaml
    {{- end }}
  containerPorts:
    http: 9090
  containerSecurityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    enabled: true
    privileged: false
    readOnlyRootFilesystem: false
    runAsNonRoot: true
    runAsUser: 1001
    seLinuxOptions: {}
    seccompProfile:
      type: RuntimeDefault
  customLivenessProbe: {}
  customReadinessProbe: {}
  customStartupProbe: {}
  enableAdminAPI: false
  enableFeatures: []
  enableRemoteWriteReceiver: false
  evaluationInterval: ""
  existingConfigmap: ""
  existingConfigmapKey: ""
  externalLabels: {}
  extraArgs: []
  extraEnvVars: []
  extraEnvVarsCM: ""
  extraEnvVarsSecret: ""
  extraScrapeConfigs: []
  extraVolumeMounts: []
  extraVolumes: []
  hostAliases: []
  image:
    digest: ""
    pullPolicy: IfNotPresent
    pullSecrets: []
    registry: docker.io
    repository: bitnami/prometheus
    tag: 2.49.1-debian-11-r0
  ingress:
    annotations: {}
    enabled: false
    extraHosts: []
    extraPaths: []
    extraRules: []
    extraTls: []
    hostname: server.prometheus.local
    ingressClassName: ""
    path: /
    pathType: ImplementationSpecific
    secrets: []
    selfSigned: false
    tls: false
  initContainers: []
  lifecycleHooks: {}
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 5
    periodSeconds: 20
    successThreshold: 1
    timeoutSeconds: 3
  logFormat: logfmt
  logLevel: info
  nodeAffinityPreset:
    key: ""
    type: ""
    values: []
  nodeSelector: {}
  pdb:
    create: false
    maxUnavailable: ""
    minAvailable: 1
  persistence:
    accessModes:
    - ReadWriteOnce
    annotations: {}
    dataSource: {}
    enabled: false
    existingClaim: ""
    mountPath: /bitnami/prometheus/data
    selector: {}
    size: 8Gi
    storageClass: ""
    subPath: ""
  podAffinityPreset: ""
  podAnnotations: {}
  podAntiAffinityPreset: soft
  podLabels: {}
  podSecurityContext:
    enabled: true
    fsGroup: 1001
    fsGroupChangePolicy: Always
    supplementalGroups: []
    sysctls: []
  priorityClassName: ""
  rbac:
    create: true
    rules: []
  readinessProbe:
    enabled: true
    failureThreshold: 5
    initialDelaySeconds: 5
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 2
  remoteWrite: []
  replicaCount: 1
  resources:
    limits: {}
    requests: {}
  retention: 10d
  retentionSize: "0"
  routePrefix: /
  schedulerName: ""
  scrapeInterval: ""
  scrapeTimeout: ""
  service:
    annotations: {}
    clusterIP: ""
    externalTrafficPolicy: Cluster
    extraPorts: []
    loadBalancerClass: ""
    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    nodePorts:
      http: ""
    ports:
      http: 80
    sessionAffinity: ClientIP
    sessionAffinityConfig: {}
    type: LoadBalancer
  serviceAccount:
    annotations: {}
    automountServiceAccountToken: true
    create: true
    name: ""
  sidecars: []
  startupProbe:
    enabled: false
    failureThreshold: 10
    initialDelaySeconds: 2
    periodSeconds: 5
    successThreshold: 1
    timeoutSeconds: 2
  terminationGracePeriodSeconds: ""
  thanos:
    containerSecurityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      enabled: true
      privileged: false
      readOnlyRootFilesystem: false
      runAsNonRoot: true
      runAsUser: 1001
      seLinuxOptions: {}
      seccompProfile:
        type: RuntimeDefault
    create: false
    customLivenessProbe: {}
    customReadinessProbe: {}
    extraArgs: []
    extraVolumeMounts: []
    image:
      digest: ""
      pullPolicy: IfNotPresent
      pullSecrets: []
      registry: docker.io
      repository: bitnami/thanos
      tag: 0.33.0-debian-11-r1
    ingress:
      annotations: {}
      enabled: false
      extraHosts: []
      extraPaths: []
      extraRules: []
      extraTls: []
      hostname: thanos.prometheus.local
      ingressClassName: ""
      path: /
      pathType: ImplementationSpecific
      secrets: []
      selfSigned: false
      tls: false
    livenessProbe:
      enabled: true
      failureThreshold: 120
      initialDelaySeconds: 0
      periodSeconds: 5
      successThreshold: 1
      timeoutSeconds: 3
    objectStorageConfig:
      secretKey: thanos.yaml
      secretName: ""
    prometheusUrl: ""
    readinessProbe:
      enabled: true
      failureThreshold: 120
      initialDelaySeconds: 0
      periodSeconds: 5
      successThreshold: 1
      timeoutSeconds: 3
    resources:
      limits: {}
      requests: {}
    service:
      annotations: {}
      clusterIP: None
      externalTrafficPolicy: Cluster
      extraPorts: []
      loadBalancerClass: ""
      loadBalancerIP: ""
      loadBalancerSourceRanges: []
      nodePorts:
        grpc: ""
      ports:
        grpc: 10901
      sessionAffinity: None
      sessionAffinityConfig: {}
      type: ClusterIP
  tolerations: []
  topologySpreadConstraints: []
  updateStrategy:
    type: RollingUpdate
volumePermissions:
  containerSecurityContext:
    runAsUser: 0
    seLinuxOptions: {}
  enabled: false
  image:
    pullPolicy: IfNotPresent
    pullSecrets: []
    registry: docker.io
    repository: bitnami/os-shell
    tag: 11-debian-11-r94
  resources:
    limits: {}
    requests: {}
