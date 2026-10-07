#!/usr/bin/env bash
# Installs Argo CD on the local kind cluster using a pinned Helm chart.
set -euo pipefail

ARGOCD_CHART_VERSION="10.10.0"
EXPECTED_CONTEXT="kind-gitops"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

CURRENT_CONTEXT="$(kubectl config current-context)"
if [ "$CURRENT_CONTEXT" != "$EXPECTED_CONTEXT" ]; then
  echo "ERROR: current context is '$CURRENT_CONTEXT', expected '$EXPECTED_CONTEXT'"
  exit 1
fi

helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo update argo

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version "$ARGOCD_CHART_VERSION" \
  -f "$SCRIPT_DIR/values.yaml" \
  --wait --timeout 10m
