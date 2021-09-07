{{/*
Defines the PodSpec for Vector.
*/}}
{{- define "vector.pod" -}}
serviceAccountName: {{ include "vector.serviceAccountName" . }} 
{{- with .Values.podSecurityContext }}
securityContext:
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
    args:
      - --config-dir
      - "/etc/vector/"
    env:
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
{{- if not .Values.customConfig }}
      - name: api
        containerPort: 8686
        protocol: TCP
{{- if or (eq .Values.role "Aggregator") (eq .Values.role "Stateless-Aggregator") }}
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
{{- end }}
{{- else if .Values.customConfig.api.enabled }}
      - name: api
        containerPort: {{ mustRegexFind "[0-9]+$" .Values.customConfig.api.address }}
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
{{- else if and .Values.persistence.enabled (eq .Values.role "Agent") }}
  - name: data
    hostPath:
      path: {{ .Values.persistence.hostPath.path | quote }}
{{- else }}
  - name: data
    emptyDir: {}
{{- end }}
  - name: config
    configMap:
      name: {{ template "vector.fullname" . }}
{{- if (eq .Values.role "Agent") }}
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
