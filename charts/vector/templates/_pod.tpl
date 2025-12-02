{{/*
Defines the PodSpec for Vector.
*/}}
{{- define "vector.pod" -}}
serviceAccountName: {{ include "vector.serviceAccountName" . }}
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
{{- if .Values.initContainers }}
initContainers:
{{- tpl (toYaml .Values.initContainers) . | nindent 2 }}
{{- end }}
containers:
{{- if .Values.configSidecar.enabled }}
  - name: config-sidecar
    {{- if .Values.configSidecar.image.sha }}
    image: "{{ .Values.configSidecar.image.registry }}/{{ .Values.configSidecar.image.repository }}:{{ .Values.configSidecar.image.tag }}@sha256:{{ .Values.configSidecar.image.sha }}"
    {{- else }}
    image: "{{ .Values.configSidecar.image.registry }}/{{ .Values.configSidecar.image.repository }}:{{ .Values.configSidecar.image.tag }}"
    {{- end }}
    imagePullPolicy: {{ .Values.configSidecar.imagePullPolicy }}
    env:
      {{- if .Values.configSidecar.ignoreAlreadyProcessed }}
      - name: IGNORE_ALREADY_PROCESSED
        value: "true"
      {{- end }}
      - name: METHOD
        value: {{ .Values.configSidecar.watchMethod }}
      - name: LABEL
        value: "{{ .Values.configSidecar.label }}"
      {{- with .Values.configSidecar.labelValue }}
      - name: LABEL_VALUE
        value: {{ quote . }}
      {{- end }}
      {{- with .Values.configSidecar.logLevel }}
      - name: LOG_LEVEL
        value: "{{ . }}"
      {{- end }}
      - name: FOLDER
        value: "{{ .Values.configSidecar.folder }}"
      - name: RESOURCE
        value: "configmap"
      {{- if .Values.configSidecar.uniqueFilenames }}
      - name: UNIQUE_FILENAMES
        value: "true"
      {{- end }}
    volumeMounts:
      - name: config
        mountPath: "{{ .Values.configSidecar.folder }}"
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
{{- with .Values.args }}
{{- $args := . }}
{{- if or $.Values.emptyConfig $.Values.configSidecar.enabled }}
  {{- if not (has "--allow-empty-config" $args) }}
    {{ $args = append $args "--allow-empty-config" }}
  {{- end }}
{{- end }}
{{- if $.Values.configSidecar.enabled }}
  {{- if not (has "--watch-config" $args) }}
    {{ $args = append $args "--watch-config"  }}
  {{- end }}
{{- end }}
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
{{- if (eq .Values.role "Agent") }}
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
{{- if or .Values.containerPorts .Values.existingConfigMaps }}
    {{- toYaml .Values.containerPorts | nindent 6 }}
{{- else if .Values.customConfig }}
    {{- include "vector.containerPorts" . | indent 6 }}
{{- else if or (eq .Values.role "Aggregator") (eq .Values.role "Stateless-Aggregator") }}
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
{{- else if (eq .Values.role "Agent") }}
      - name: prom-exporter
        containerPort: 9090
        protocol: TCP
{{- end }}
{{- with .Values.livenessProbe }}
    livenessProbe:
      {{- toYaml . | trim | nindent 6 }}
{{- end }}
{{- with .Values.readinessProbe }}
    readinessProbe:
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
{{- if not .Values.configSidecar.enabled }}
        readOnly: true
{{- end }}
{{- if (eq .Values.role "Agent") }}
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
{{- toYaml . | nindent 2 }}
{{- end }}
volumes:
{{- if and .Values.persistence.enabled (eq .Values.role "Aggregator") }}
{{- with .Values.persistence.existingClaim }}
  - name: data
    persistentVolumeClaim:
      claimName: {{ . }}
{{- end }}
{{- else if (ne .Values.role "Agent") }}
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
{{- if (eq .Values.role "Agent") }}
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
