{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gitfence.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gitfence.fullname" -}}
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
{{- define "gitfence.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gitfence.labels" -}}
helm.sh/chart: {{ include "gitfence.chart" . }}
{{ include "gitfence.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gitfence.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gitfence.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Control the range of entropy bits (initContainers.entropyWatermark)
*/}}
{{- define "gitfence.entropyWatermark" -}}
{{- $entropyWatermark := min .Values.initContainers.entropyWatermark 2048 }}
{{- printf "%d" (max $entropyWatermark 512) }}
{{- end }}

{{/*
Control the minumum ttl of the entropy seeding process (initContainers.timeToLive)
*/}}
{{- define "gitfence.entropySeedingTimeout" -}}
{{- $timeToLive := min (lower .Values.initContainers.timeToLive | trimSuffix "m") 10 }}
{{- printf "%dm" (max $timeToLive 3) }}
{{- end }}
