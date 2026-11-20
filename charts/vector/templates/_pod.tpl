{{/*
Defines the PodSpec for Vector.
*/}}
{{- define "vector.pod" -}}
serviceAccountName: {{ include "vector.serviceAccountName" . }}
{{- if .Values.configSidecar.enabled }}
{{- /* The config sidecar needs API access, which overrides the ServiceAccount's automount setting. */}}
automountServiceAccountToken: true
{{- end }}
{{- with .Values.podHostNetwork }}
hostNetwork: {{ . }}
{{- end }}
{{- with .Values.podSecurityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.podPriorityClassName }}
priorityClassName: {{ . }}
{{- end }}
{{- with .Values.shareProcessNamespace }}
shareProcessNamespace: {{ . }}
{{- end }}
{{- with .Values.dnsPolicy }}
dnsPolicy: {{ . }}
{{- end }}
{{- with .Values.dnsConfig }}
dnsConfig:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.image.pullSecrets }}
imagePullSecrets:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.hostAliases }}
hostAliases:
{{ toYaml . | indent 2 }}
{{- end }}
{{- if or .Values.initContainers .Values.configSidecar.enabled }}
initContainers:
{{- if .Values.configSidecar.enabled }}
  {{- /* Populate the config directory once before Vector starts. Otherwise Vector starts with an empty configuration and
         keeps the settings that cannot be changed at runtime, e.g. the API address, when the sidecar delivers the config later. */}}
  - {{ include "vector.configSidecar.container" (dict "root" . "name" "config-sidecar-init" "method" "LIST") | nindent 4 | trim }}
{{- end }}
{{- with .Values.initContainers }}
{{- tpl (toYaml .) $ | nindent 2 }}
{{- end }}
{{- end }}
containers:
{{- if .Values.configSidecar.enabled }}
  - {{ include "vector.configSidecar.container" (dict "root" . "name" "config-sidecar" "method" .Values.configSidecar.watchMethod) | nindent 4 | trim }}
{{- end }}
  - name: vector
{{- with .Values.securityContext }}
    securityContext:
{{ toYaml . | indent 6 }}
{{- end }}
    image: "{{ include "vector.image" . }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
{{- with .Values.command }}
    command:
    {{- toYaml . | nindent 6 }}
{{- end }}
{{- $args := list }}
{{- if .Values.args }}
{{- $args = .Values.args }}
{{- end }}
{{- if or $.Values.emptyConfig $.Values.configSidecar.enabled }}
  {{- if not (has "--allow-empty-config" $args) }}
  {{- $args = append $args "--allow-empty-config" }}
  {{- end }}
  {{- $hasConfigDir := false }}
  {{- range $i, $arg := $args }}
    {{- $isConfigDirFlag := false }}
    {{- $dir := "" }}
    {{- if eq $arg "--config-dir" }}
      {{- $isConfigDirFlag = true }}
      {{- if lt (add1 $i) (len $args) }}
        {{- $dir = index $args (add1 $i) }}
      {{- end }}
    {{- else if hasPrefix "--config-dir=" $arg }}
      {{- $isConfigDirFlag = true }}
      {{- $dir = trimPrefix "--config-dir=" $arg }}
    {{- end }}
    {{- if $isConfigDirFlag }}
      {{- $hasConfigDir = true }}
      {{- if and $.Values.configSidecar.enabled (ne (trimSuffix "/" $dir) "/etc/vector") }}
        {{- $msg := "When configSidecar is enabled, args must not contain --config-dir pointing outside /etc/vector/. " }}
        {{- $msg = printf "%sThe sidecar is hardcoded to write to /etc/vector/ and Vector must watch the same directory. " $msg }}
        {{- $msg = printf "%sRemove --config-dir from args or disable configSidecar." $msg }}
        {{- fail $msg }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if not $hasConfigDir }}
  {{- $args = concat $args (list "--config-dir" "/etc/vector/") }}
  {{- end }}
{{- end }}
{{- if $.Values.configSidecar.enabled }}
  {{- if not (has "--watch-config" $args) }}
  {{- $args = append $args "--watch-config" }}
  {{- end }}
{{- end }}
{{- if $args }}
    args:
    {{- toYaml $args | nindent 6 }}
{{- end }}
    env:
      - name: VECTOR_LOG
        value: "{{ .Values.logLevel | default "info" }}"
{{- if .Values.env }}
{{- with .Values.env }}
    {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
{{- if (eq (lower .Values.role) "agent") }}
      - name: VECTOR_SELF_NODE_NAME
        valueFrom:
          fieldRef:
            fieldPath: spec.nodeName
      - name: VECTOR_SELF_POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: VECTOR_SELF_POD_NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: PROCFS_ROOT
        value: "/host/proc"
      - name: SYSFS_ROOT
        value: "/host/sys"
{{- end }}
{{- if .Values.envFrom }}
{{- with .Values.envFrom }}
    envFrom:
    {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    ports:
{{- if or .Values.containerPorts .Values.existingConfigMaps .Values.emptyConfig }}
    {{- toYaml .Values.containerPorts | nindent 6 }}
{{- else if .Values.customConfig }}
    {{- include "vector.containerPorts" . | indent 6 }}
{{- else if or (eq (lower .Values.role) "aggregator") (eq (lower .Values.role) "stateless-aggregator") }}
      - name: datadog-agent
        containerPort: 8282
        protocol: TCP
      - name: fluent
        containerPort: 24224
        protocol: TCP
      - name: logstash
        containerPort: 5044
        protocol: TCP
      - name: splunk-hec
        containerPort: 8080
        protocol: TCP
      - name: statsd
        containerPort: 8125
        protocol: TCP
      - name: syslog
        containerPort: 9000
        protocol: TCP
      - name: vector
        containerPort: 6000
        protocol: TCP
      - name: prom-exporter
        containerPort: 9090
        protocol: TCP
{{- else if (eq (lower .Values.role) "agent") }}
      - name: prom-exporter
        containerPort: 9090
        protocol: TCP
{{- end }}
{{- with .Values.livenessProbe }}
    livenessProbe:
      {{- toYaml . | trim | nindent 6 }}
{{- end }}
{{- if .Values.readinessProbe }}
    readinessProbe:
      {{- toYaml .Values.readinessProbe | trim | nindent 6 }}
{{- else if and (not .Values.existingConfigMaps) (not .Values.customConfig) (not .Values.emptyConfig) }}
    readinessProbe:
      httpGet:
        path: /health
        port: 8686
{{- end }}
{{- with .Values.startupProbe }}
    startupProbe:
      {{- toYaml . | trim | nindent 6 }}
{{- end }}
{{- with .Values.resources }}
    resources:
{{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.lifecycle }}
    lifecycle:
{{- toYaml . | nindent 6 }}
{{- end }}
    volumeMounts:
      - name: data
        {{- if or .Values.emptyConfig .Values.configSidecar.enabled }}
        mountPath: "/var/lib/vector/"
        {{- else if .Values.existingConfigMaps }}
        mountPath: "{{ if .Values.dataDir }}{{ .Values.dataDir }}{{ else }}{{ fail "Specify `dataDir` if you're using `existingConfigMaps`" }}{{ end }}"
        {{- else }}
        mountPath: "{{ .Values.customConfig.data_dir | default "/vector-data-dir" }}"
        {{- end }}
      - name: config
        mountPath: "/etc/vector/"
        readOnly: true
{{- if (eq (lower .Values.role) "agent") }}
{{- with .Values.defaultVolumeMounts }}
{{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
{{- with .Values.extraVolumeMounts }}
{{- toYaml . | nindent 6 }}
{{- end }}
{{- if .Values.extraContainers }}
{{- tpl (toYaml .Values.extraContainers) . | nindent 2 }}
{{- end }}
terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
{{- with .Values.nodeSelector }}
nodeSelector:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with  .Values.topologySpreadConstraints }}
topologySpreadConstraints:
{{- range $_, $entry := . }}
{{- if not (hasKey $entry "labelSelector") }}
  {{- $ls := dict -}}
  {{- $_ := set $ls "labelSelector" dict -}}
  {{- $_ := set $ls.labelSelector "matchLabels" (include "vector.selectorLabels" $ | fromYaml) }}
  {{- $entry := merge $entry $ls }}
{{- end }}
{{- end }}
{{- toYaml . | nindent 2 }}
{{- end }}
volumes:
{{- if and .Values.persistence.enabled (eq (lower .Values.role) "aggregator") }}
{{- with .Values.persistence.existingClaim }}
  - name: data
    persistentVolumeClaim:
      claimName: {{ . }}
{{- end }}
{{- else if (ne (lower .Values.role) "agent") }}
  - name: data
    emptyDir: {}
{{- end }}
  - name: config
{{- if or .Values.emptyConfig .Values.configSidecar.enabled }}
    emptyDir: {}
{{- else }}
    projected:
      sources:
{{- if .Values.existingConfigMaps }}
  {{- range .Values.existingConfigMaps }}
        - configMap:
            name: {{ . }}
  {{- end }}
{{- else }}
        - configMap:
            name: {{ template "vector.fullname" . }}
{{- end }}
{{- end }}
{{- if (eq (lower .Values.role) "agent") }}
  - name: data
  {{- if .Values.persistence.hostPath.enabled }}
    hostPath:
      path: {{ .Values.persistence.hostPath.path | quote }}
  {{- else }}
    emptyDir: {}
  {{- end }}
    {{- with .Values.defaultVolumes }}
    {{- toYaml . | nindent 2 }}
    {{- end }}
{{- end }}
{{- with .Values.extraVolumes }}
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
