#!/usr/bin/env bash
#
# Regenerate the auto-synced blocks in docs/blueprints.md from the org's public
# repos: a Mermaid graph (the reference -> its variants) and a table.
# Requires `gh` (authenticated) and `jq`.
#
set -euo pipefail

ORG="miragon-blueprints"
DOC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/docs/blueprints.md"

# One entry per non-archived repo, excluding this .github repo itself.
# `fullstack-example` (the reference) is pinned first; the rest are alphabetical.
repos="$(
  gh api "orgs/$ORG/repos?per_page=100&type=public" --paginate \
    --jq '.[] | select(.archived == false and .name != ".github") | {name, description}' \
  | jq -s 'sort_by(.name != "fullstack-example", .name)'
)"

# Replace everything between "<!-- BEGIN:$1 ... -->" and "<!-- END:$1 -->" with stdin.
inject() {
  local marker="$1" block; block="$(mktemp)"
  cat > "$block"
  local out; out="$(mktemp)"
  awk -v m="$marker" -v tf="$block" '
    $0 ~ ("<!-- BEGIN:" m) { print; while ((getline l < tf) > 0) print l; close(tf); skip = 1; next }
    $0 ~ ("<!-- END:" m " -->") { skip = 0 }
    skip != 1 { print }
  ' "$DOC" > "$out"
  mv "$out" "$DOC"
  rm -f "$block"
}

# Mermaid: the reference node, then one edge to each variant.
jq -r --arg org "$ORG" '
  (.[0].name)                              as $ref |
  ($ref | gsub("[^a-zA-Z0-9]"; "_"))       as $rid |
  ["```mermaid", "graph LR",
   "  \($rid)[\"\($ref)<br/>reference\"]:::ref"]
  + (.[1:] | map("  \($rid) --> " + (.name | gsub("[^a-zA-Z0-9]"; "_")) + "[\"\(.name)\"]"))
  + ["  classDef ref fill:#1f6feb,stroke:#1f6feb,color:#fff", "```"]
  | .[]
' <<<"$repos" | inject diagram

# Table: name (linked) + description.
{
  echo "| Blueprint | What it demonstrates |"
  echo "| --- | --- |"
  jq -r --arg org "$ORG" '.[] |
    "| [`\(.name)`](https://github.com/\($org)/\(.name)) | \((.description // "") | gsub("\\|"; "\\|")) |"
  ' <<<"$repos"
} | inject landscape

echo "Updated $DOC"
