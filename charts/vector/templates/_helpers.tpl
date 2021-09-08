{{/*
Expand the name of the chart.
*/}}
{{- define "vector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vector.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vector.labels" -}}
helm.sh/chart: {{ include "vector.chart" . }}
{{ include "vector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if or (ne .Values.role "Agent") (ne .Values.role "Aggregator") (ne .Values.role "Stateless-Aggregator") }}
app.kubernetes.io/component: {{ .Values.role }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vector.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vector.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate an array of ServicePorts based on customConfig
*/}}
{{- define "vector.ports" -}}
{{- range $componentKind, $configs := .Values.customConfig }}
{{- if eq $componentKind "sources" }}
{{- range $componentId, $componentConfig := $configs }}
{{- if (hasKey $componentConfig "address") }}
{{- tuple $componentId $componentConfig | include "_helper.generatePort" -}}
{{- end }}
{{- end }}
{{- else if eq $componentKind "sinks" }}
{{- range $componentId, $componentConfig := $configs }}
{{- if (hasKey $componentConfig "address") }}
{{- tuple $componentId $componentConfig | include "_helper.generatePort" -}}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate a single ServicePort based on a component configuration
*/}}
{{- define "_helper.generatePort" -}}
{{- $name := index . 0 | kebabcase -}}
{{- $config := index . 1 -}}
{{- $port := mustRegexFind "[0-9]+$" (get $config "address") -}}
{{- $protocol := default (get $config "mode" | upper) "TCP" }}
- name: {{ $name }}
  port: {{ $port }}
  protocol: {{ $protocol }}
  targetPort: {{ $port }}
{{- if not (mustHas $protocol (list "TCP" "UDP")) }}
{{ fail "Component's `mode` is not a supported protocol, please raise a issue at https://github.com/timberio/vector" }}
{{- end }}
{{- end }}

{{/*
Generate an array of ContainerPorts based on customConfig
*/}}
{{- define "vector.containerPorts" -}}
{{- range $componentKind, $configs := .Values.customConfig }}
{{- if eq $componentKind "sources" }}
{{- range $componentId, $componentConfig := $configs }}
{{- if (hasKey $componentConfig "address") }}
{{- tuple $componentId $componentConfig | include "_helper.generateContainerPort" -}}
{{- end }}
{{- end }}
{{- else if eq $componentKind "sinks" }}
{{- range $componentId, $componentConfig := $configs }}
{{- if (hasKey $componentConfig "address") }}
{{- tuple $componentId $componentConfig | include "_helper.generateContainerPort" -}}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate a single ContainerPort based on a component configuration
*/}}
{{- define "_helper.generateContainerPort" -}}
{{- $name := index . 0 | kebabcase -}}
{{- $config := index . 1 -}}
{{- $port := mustRegexFind "[0-9]+$" (get $config "address") -}}
{{- $protocol := default (get $config "mode" | upper) "TCP" }}
- name: {{ $name | trunc 15 | trimSuffix "-" }}
  containerPort: {{ $port }}
  protocol: {{ $protocol }}
{{- if not (mustHas $protocol (list "TCP" "UDP")) }}
{{ fail "Component's `mode` is not a supported protocol, please raise a issue at https://github.com/timberio/vector" }}
{{- end }}
{{- end }}
