{{/*
Helm template helpers para geração de Cilium Network Policies
Suporta: FQDN, IP, CIDR, Namespaces, e outros tipos
*/}}

{{/*
Define o tipo de endpoint (fqdn, ip, cidr)
Auto-detecta se não for explícito
*/}}
{{- define "networkPolicy.detectEndpointType" -}}
{{- if contains "/" . -}}cidr{{- else if regexMatch "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$" . -}}ip{{- else if eq . "world" -}}world{{- else -}}fqdn{{- end -}}
{{- end -}}

{{/*
Constrói regras de egress para FQDN (usando podSelector e FQDNSelector)
*/}}
{{- define "networkPolicy.egressFQDN" -}}
{{- range .endpoints }}
- to:
    - podSelector: {}
  toPorts:
    - ports:
      {{- range .ports | default (list 443) }}
      - port: {{ . }}
        protocol: {{ .protocol | default "TCP" }}
      {{- end }}
{{- end }}
{{- end -}}

{{/*
Constrói regras de egress para IP ou CIDR
*/}}
{{- define "networkPolicy.egressIPCIDR" -}}
{{- $ports := .ports | default (list 443) }}
{{- $protocol := .protocol | default "TCP" }}
- to:
    - cidrSelector: "{{ .endpoint }}"
  toPorts:
    - ports:
      {{- range $ports }}
      - port: {{ . }}
        protocol: {{ $protocol }}
      {{- end }}
{{- end -}}

{{/*
Constrói regras de ingress de um namespace específico
*/}}
{{- define "networkPolicy.ingressNamespace" -}}
{{- $ports := .ports | default (list 8080) }}
{{- $protocol := .protocol | default "TCP" }}
- from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: "{{ .source }}"
  toPorts:
    - ports:
      {{- range $ports }}
      - port: {{ . }}
        protocol: {{ $protocol }}
      {{- end }}
{{- end -}}

{{/*
Constrói regras de egress para um namespace específico
*/}}
{{- define "networkPolicy.egressNamespace" -}}
{{- $ports := .ports | default (list 8080) }}
{{- $protocol := .protocol | default "TCP" }}
- to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: "{{ .destination }}"
  toPorts:
    - ports:
      {{- range $ports }}
      - port: {{ . }}
        protocol: {{ $protocol }}
      {{- end }}
{{- end -}}

{{/*
Constrói regras de ingress de CIDR específico
*/}}
{{- define "networkPolicy.ingressCIDR" -}}
{{- $ports := .ports | default (list 443) }}
{{- $protocol := .protocol | default "TCP" }}
- from:
    - cidrSelector: "{{ .endpoint }}"
  toPorts:
    - ports:
      {{- range $ports }}
      - port: {{ . }}
        protocol: {{ $protocol }}
      {{- end }}
{{- end -}}

{{/*
Helper: Gera uma NetworkPolicy completa baseado no tipo
Parâmetros:
- name: nome da política
- namespace: namespace de destino
- policyType: ingress ou egress
- rule: a regra já formatada
*/}}
{{- define "networkPolicy.template" -}}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ .name }}
  namespace: {{ .namespace }}
  labels:
    app.kubernetes.io/part-of: network-policies
    app.kubernetes.io/managed-by: helm
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
    - {{ .policyType | title }}
  {{- if eq .policyType "ingress" }}
  ingress:
{{ .rules | indent 4 }}
  {{- else if eq .policyType "egress" }}
  egress:
{{ .rules | indent 4 }}
  {{- end }}
{{- end -}}
