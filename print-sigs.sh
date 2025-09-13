#!/usr/bin/env bash
# Author: Player
# Usage: forge build && print-sigs [--entrypoints] <ContractName|Path> [more...]

ENTRYPOINTS_ONLY=false
if [ "$1" == "--entrypoints" ]; then
  ENTRYPOINTS_ONLY=true
  shift
fi

if [ $# -eq 0 ]; then
  echo "Usage: $0 [--entrypoints] <ContractName|Path> [more...]"
  exit 1
fi

# jq program: output TSV rows: contract, name, params, visibility, mutability, modifiers, returns
JQ_PROG='
  .ast
  | .nodes[]
  | select(.nodeType == "ContractDefinition")
  | . as $contract
  | .nodes[]
  | select(.nodeType == "FunctionDefinition")
  | [
      $contract.name,
      .name,
      (.parameters.parameters | map(.typeDescriptions.typeString + " " + (.name // "")) | join(", ")),
      .visibility,
      .stateMutability,
      (if .modifiers | length > 0 then (.modifiers | map(.modifierName.name) | join(" ")) else "" end),
      (if .returnParameters.parameters | length > 0
       then (.returnParameters.parameters | map(.typeDescriptions.typeString + " " + (.name // "")) | join(", "))
       else "" end)
    ]
  | @tsv
'

process_artifact() {
  local artifact=$1
  local contract=$(basename "$artifact" .json)

  output=$(jq -r "$JQ_PROG" "$artifact")
  [ -z "$output" ] && return  # skip if no functions

  echo "## $contract"
  echo

  jq -r "$JQ_PROG" "$artifact" | awk -F'\t' -v onlyEntrypoints="$ENTRYPOINTS_ONLY" '
    BEGIN {
      order[1] = "external/public mutating"
      order[2] = "internal/private mutating"
      order[3] = "external/public view/pure"
      order[4] = "internal/private view/pure"
      order[5] = "others"
    }
    {
      contract=$1; name=$2; params=$3; vis=$4; mut=$5; mods=$6; rets=$7;

      # classify
      group="others"
      if ((vis=="external"||vis=="public") && (mut=="nonpayable"||mut=="payable")) group="external/public mutating"
      else if ((vis=="internal"||vis=="private") && (mut=="nonpayable"||mut=="payable")) group="internal/private mutating"
      else if ((vis=="external"||vis=="public") && (mut=="view"||mut=="pure")) group="external/public view/pure"
      else if ((vis=="internal"||vis=="private") && (mut=="view"||mut=="pure")) group="internal/private view/pure"

      # build signature
      sig="function " name "(" params ") " vis " " mut
      if (mods != "") sig=sig " " mods
      if (rets != "") sig=sig " returns (" rets ")"

      out[group] = out[group] "\n" sig "\n"
    }
    END {
      for (i=1; i<=5; i++) {
        g=order[i]
        if (onlyEntrypoints=="true" && g != "external/public mutating") continue
        if (out[g] != "") {
          print "#### " g
          print ""
          print out[g]
        }
      }
    }
  '
  echo
}

for arg in "$@"; do
  if [ -d "$arg" ]; then
    find "$arg" -type f -name "*.sol" | while read -r sol; do
      base=$(basename "$sol")
      find out -type f -path "*/$base/*.json" | while read -r artifact; do
        process_artifact "$artifact"
      done
    done
  elif [ -f "$arg" ]; then
    base=$(basename "$arg")
    find out -type f -path "*/$base/*.json" | while read -r artifact; do
      process_artifact "$artifact"
    done
  else
    find out -type f -name "$arg.json" | while read -r artifact; do
      process_artifact "$artifact"
    done
  fi
done

