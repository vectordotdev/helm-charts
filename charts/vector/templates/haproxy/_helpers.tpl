{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "haproxy.fullname" -}}
{{- printf "%s-haproxy" (include "vector.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Build a valid image reference from available fields:
  - tag only:         repo:tag
  - sha/digest only:  repo@sha256:…
  - tag@digest:       repo:tag@sha256:…
  - nothing set:      repo:<Chart.AppVersion>
*/}}
{{- define "haproxy.image" -}}
{{- $repo   := .Values.haproxy.image.repository -}}
{{- $tagRaw := .Values.haproxy.image.tag -}}
{{- $shaRaw := (coalesce .Values.haproxy.image.sha .Values.haproxy.image.digest) | default "" -}}
{{- $tag    := trim $tagRaw -}}

{{- /* Normalize SHA to ensure it has sha256: prefix for backward compatibility */ -}}
{{- $sha := "" -}}
{{- if $shaRaw -}}
  {{- if hasPrefix "sha256:" $shaRaw -}}
    {{- $sha = $shaRaw -}}
  {{- else -}}
    {{- $sha = printf "sha256:%s" $shaRaw -}}
  {{- end -}}
{{- end -}}

{{- /* Case 1: digest field wins */ -}}
{{- if $sha -}}
  {{- if $tag -}}
    {{- printf "%s:%s@%s" $repo $tag $sha -}}
  {{- else -}}
    {{- printf "%s@%s" $repo $sha -}}
  {{- end -}}

{{- /* Case 2: tag looks like a digest */ -}}
{{- else if hasPrefix "sha256:" $tag -}}
  {{- printf "%s@%s" $repo $tag -}}

{{- /* Case 3: tag@digest combined syntax */ -}}
{{- else if contains "@sha256:" $tag -}}
  {{- $parts := splitList "@" $tag -}}
  {{- printf "%s:%s@%s" $repo (index $parts 0) (index $parts 1) -}}

{{- /* Case 4: normal tag */ -}}
{{- else if $tag -}}
  {{- printf "%s:%s" $repo $tag -}}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "haproxy.labels" -}}
helm.sh/chart: {{ include "vector.chart" . }}
{{ include "haproxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Values.haproxy.image.tag | quote }}
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
{{- if or (.Capabilities.APIVersions.Has "autoscaling/v2/HorizontalPodAutoscaler") (semverCompare ">=1.23" .Capabilities.KubeVersion.Version) -}}
"autoscaling/v2"
{{- else -}}
"autoscaling/v2beta2"
{{- end -}}
{{- end -}}
