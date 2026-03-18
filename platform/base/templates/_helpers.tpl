{{- define "ns.name" -}}
{{- printf "%s-%s-%s" .Values.team .Values.project .Values.environment -}}
{{- end -}}

{{- define "ns.labels" -}}
claro.com.br/team: {{ required "team é obrigatório" .Values.team | quote }}
claro.com.br/owner: {{ required "owner é obrigatório" .Values.owner | quote }}
claro.com.br/project: {{ required "project é obrigatório" .Values.project | quote }}
claro.com.br/environment: {{ required "environment é obrigatório" .Values.environment | quote }}
claro.com.br/cost-center: {{ required "costCenter é obrigatório" .Values.costCenter | quote }}
claro.com.br/managed-by: "gitops"
{{- end -}}
