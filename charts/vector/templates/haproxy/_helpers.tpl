{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "haproxy.fullname" -}}
{{- printf "%s-haproxy" (include "vector.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Normalize the image tag, preserving explicit zero values while accepting null.
*/}}
{{- define "haproxy.image.tag" -}}
{{- if ne .Values.haproxy.image.tag nil -}}
{{- .Values.haproxy.image.tag | toString | trim -}}
{{- end -}}
{{- end -}}

{{/*
Build a valid image reference from available fields:
  - tag only:         repo:tag
  - sha/digest only:  repo@sha256:…
  - tag@digest:       repo:tag@sha256:…
  - nothing set:      repo:latest
*/}}
{{- define "haproxy.image" -}}
{{- $repo   := .Values.haproxy.image.repository | default "haproxytech/haproxy-alpine" -}}
{{- $tag := include "haproxy.image.tag" . -}}
{{- $shaRaw := .Values.haproxy.image.sha | default "" | toString | trim -}}
{{- $digest := .Values.haproxy.image.digest | default "" | toString | trim -}}
{{- $shaRaw = coalesce $shaRaw $digest | default "" -}}

{{- /* Extract an embedded digest before applying the explicit SHA override. */ -}}
{{- if hasPrefix "sha256:" $tag -}}
  {{- $shaRaw = default $tag $shaRaw -}}
  {{- $tag = "" -}}
{{- else if contains "@sha256:" $tag -}}
  {{- $parts := splitList "@" $tag -}}
  {{- $shaRaw = default (index $parts 1) $shaRaw -}}
  {{- $tag = index $parts 0 -}}
{{- end -}}

{{- /* Normalize SHA to ensure it has sha256: prefix for backward compatibility */ -}}
{{- $sha := "" -}}
{{- if $shaRaw -}}
  {{- if hasPrefix "sha256:" $shaRaw -}}
    {{- $sha = $shaRaw -}}
  {{- else -}}
    {{- $sha = printf "sha256:%s" $shaRaw -}}
  {{- end -}}
{{- end -}}

{{- if and $tag $sha -}}
  {{- printf "%s:%s@%s" $repo $tag $sha -}}
{{- else if $sha -}}
  {{- printf "%s@%s" $repo $sha -}}
{{- else if $tag -}}
  {{- printf "%s:%s" $repo $tag -}}
{{- else -}}
  {{- printf "%s:latest" $repo -}}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "haproxy.labels" -}}
helm.sh/chart: {{ include "vector.chart" . }}
{{ include "haproxy.selectorLabels" . }}
{{- $tag := include "haproxy.image.tag" . }}
{{- $version := first (splitList "@" $tag) }}
{{- if and (not (hasPrefix "sha256:" $tag)) (le (len $version) 63) (regexMatch "^[a-zA-Z0-9]([a-zA-Z0-9_.-]*[a-zA-Z0-9])?$" $version) }}
app.kubernetes.io/version: {{ $version | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "haproxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: load-balancer
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "haproxy.serviceAccountName" -}}
{{- if .Values.haproxy.serviceAccount.create }}
{{- default (include "haproxy.fullname" .) .Values.haproxy.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.haproxy.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for HPA autoscaling APIs.
*/}}
{{- define "autoscaling.apiVersion" -}}
"autoscaling/v2"
{{- end -}}
