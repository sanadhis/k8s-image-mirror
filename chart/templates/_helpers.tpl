{{- define "k8s-image-mirror.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "k8s-image-mirror.fullname" -}}
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

{{- define "k8s-image-mirror.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "k8s-image-mirror.labels" -}}
helm.sh/chart: {{ include "k8s-image-mirror.chart" . }}
{{ include "k8s-image-mirror.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "k8s-image-mirror.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-image-mirror.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "k8s-image-mirror.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "k8s-image-mirror.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "k8s-image-mirror.targetRegistrySecretName" -}}
{{- if .Values.credentials.existingTargetRegistrySecret }}
{{- .Values.credentials.existingTargetRegistrySecret }}
{{- else }}
{{- include "k8s-image-mirror.fullname" . }}-target-credentials
{{- end }}
{{- end }}

{{- define "k8s-image-mirror.sourceRegistrySecretName" -}}
{{- if .Values.credentials.existingSourceRegistrySecret }}
{{- .Values.credentials.existingSourceRegistrySecret }}
{{- else }}
{{- include "k8s-image-mirror.fullname" . }}-source-credentials
{{- end }}
{{- end }}
