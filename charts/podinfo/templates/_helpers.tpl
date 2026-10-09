{{/* Common labels applied to every resource */}}
{{- define "podinfo.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/* Selector labels: must never change after first deploy */}}
{{- define "podinfo.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Pod template shared by Deployment and Rollout */}}
{{- define "podinfo.podTemplate" -}}
metadata:
  labels:
    {{- include "podinfo.labels" . | nindent 4 }}
spec:
  securityContext:
    {{- toYaml .Values.podSecurityContext | nindent 4 }}
  containers:
    - name: podinfo
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      ports:
        - name: http
          containerPort: {{ .Values.service.port }}
          protocol: TCP
      env:
        - name: PODINFO_UI_MESSAGE
          value: {{ .Values.ui.message | quote }}
        - name: PODINFO_UI_COLOR
          value: {{ .Values.ui.color | quote }}
      livenessProbe:
        httpGet:
          path: /healthz
          port: http
      readinessProbe:
        httpGet:
          path: /readyz
          port: http
      resources:
        {{- toYaml .Values.resources | nindent 8 }}
      securityContext:
        {{- toYaml .Values.securityContext | nindent 8 }}
      volumeMounts:
        - name: tmp
          mountPath: /tmp
  volumes:
    - name: tmp
      emptyDir: {}
{{- end }}
