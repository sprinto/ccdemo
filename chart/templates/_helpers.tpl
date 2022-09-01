{{/*
Create a fully qualified ccdemo name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "sinch.cc2022.ccdemo.fullname" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sinch.cc2022.ccdemo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Labels.
*/}}
{{- define "sinch.cc2022.ccdemo.labels" -}}
app.kubernetes.io/name: {{ template "sinch.cc2022.ccdemo.fullname" . }}
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ template "sinch.cc2022.ccdemo.chart" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "sinch.cc2022.ccdemo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sinch.cc2022.ccdemo.fullname" . }}
{{- end -}}


{{/*
Create image registry url
*/}}
{{- define "sinch.cc2022.ccdemo.registryUrl" -}}
{{- .Values.imageCredentials.registry.url -}}
{{- end -}}
