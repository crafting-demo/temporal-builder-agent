#!/usr/bin/env bash
# Install (or update) the Temporal Workflow Builder agents in a Crafting org.
#
# Usage: ./install.sh [--shared] [--org ORG] [--folder FOLDER] [--render]
#   --shared   install as org-shared agents (default: personal agents)
#   --org      Crafting org name (default: the cs CLI default org)
#   --folder   Crafting folder to install into (default: the cs CLI default folder)
#   --render   print the rendered temporal-builder definition and exit
set -euo pipefail

cd "$(dirname "$0")"

SHARED=()
CS_ARGS=()
RENDER_ONLY=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --shared) SHARED=(--shared) ;;
    --org) CS_ARGS+=(-O "$2"); shift ;;
    --folder) CS_ARGS+=(--folder "$2"); shift ;;
    --render) RENDER_ONLY=true ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
  shift
done

render_builder() {
  cat agents/temporal-builder.base.yaml
  echo "instructions: |"
  awk -v stack="templates/temporal-stack.yaml" '
    /\{\{TEMPORAL_STACK\}\}/ {
      while ((getline line < stack) > 0) print (line == "" ? "" : "  " line)
      next
    }
    { print ($0 == "" ? "" : "  " $0) }
  ' agents/temporal-builder.md
}

if $RENDER_ONLY; then
  render_builder
  exit 0
fi

command -v cs >/dev/null || { echo "the Crafting CLI (cs) is required" >&2; exit 1; }

install_agent() {
  local name="$1" file="$2"
  if cs "${CS_ARGS[@]}" llm agent show "$name" "${SHARED[@]}" >/dev/null 2>&1; then
    cs "${CS_ARGS[@]}" llm agent update "$name" "$file" "${SHARED[@]}"
  else
    cs "${CS_ARGS[@]}" llm agent create "$name" "$file" "${SHARED[@]}"
  fi
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
render_builder > "$tmp/temporal-builder.yaml"

# The researcher is installed first so the builder can resolve it as a sub-agent.
install_agent temporal-researcher agents/temporal-researcher.yaml
install_agent temporal-builder "$tmp/temporal-builder.yaml"

scope="personal"
[[ ${#SHARED[@]} -gt 0 ]] && scope="org-shared"
echo
echo "Installed temporal-builder and temporal-researcher as $scope agents."
echo "In Crafting's Agent UI, start a new session and select temporal-builder."
