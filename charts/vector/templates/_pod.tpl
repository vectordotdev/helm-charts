{{/*
Defines the PodSpec for Vector.
*/}}
{{- define "vector.pod" -}}
serviceAccountName: {{ include "vector.serviceAccountName" . }} 
{{- with .Values.podSecurityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.priorityClassName }}
priorityClassName: {{ . }}
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
containers:
  - name: vector
{{- with .Values.securityContext }}
    securityContext:
{{ toYaml . | indent 6 }}
{{- end }}
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
{{- with .Values.command }}
    command:
    {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.args }}
    args:
    {{- toYaml . | nindent 6 }}
{{- end }}
    env:
{{- with .Values.env }}
    {{- toYaml . | nindent 6 }}
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
    ports:
{{- if .Values.customConfig }}
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
    volumeMounts:
      - name: data
        mountPath: "{{ .Values.customConfig.data_dir | default "/vector-data-dir" }}"
      - name: config
        mountPath: "/etc/vector/"
        readOnly: true
{{- if (eq .Values.role "Agent") }}
      - name: var-log
        mountPath: "/var/log/"
        readOnly: true
      - name: var-lib
        mountPath: "/var/lib"
        readOnly: true
      - name: procfs
        mountPath: "/host/proc"
        readOnly: true
      - name: sysfs
        mountPath: "/host/sys"
        readOnly: true
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
    projected:
      sources:
        - configMap:
            name: {{ if .Values.existingConfigMap }}{{ .Values.existingConfigMap }}{{ else }}{{ template "vector.fullname" . }}{{ end }}
{{- with .Values.extraConfigs }}
  {{- range . }}
        - configMap:
            name: {{ . }}
  {{- end }}
{{- end }}
{{- if (eq .Values.role "Agent") }}
  - name: data
    hostPath:
      path: {{ .Values.persistence.hostPath.path | quote }}
  - name: var-log
    hostPath:
      path: "/var/log/"
  - name: var-lib
    hostPath:
      path: "/var/lib/"
  - name: procfs
    hostPath:
      path: "/proc"
  - name: sysfs
    hostPath:
      path: "/sys"
{{- end }}
{{- end }}
