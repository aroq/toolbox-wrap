#!/usr/bin/env bash

# Set strict bash mode
set -euo pipefail

. /toolbox/toolbox-utils/includes/log.sh

TOOLBOX_TOOL=${TOOLBOX_TOOL:-${1}}
TOOLBOX_TOOL_PATH=${TOOLBOX_TOOL_PATH:-}
TOOLBOX_TOOL_DIRS=${TOOLBOX_TOOL_DIRS:-toolbox}
TOOLBOX_WRAP_ENTRYPOINT_MODE=${TOOLBOX_WRAP_ENTRYPOINT_MODE:-run}

_log TRACE "entrypoint.sh: Inside docker (aroq/toolbox-wrap)"
_log DEBUG "TOOLBOX_TOOL: ${TOOLBOX_TOOL}"
_log DEBUG "TOOLBOX_TOOL_DIRS: ${TOOLBOX_TOOL_DIRS}"

if [ ! -f "${TOOLBOX_TOOL}" ]; then
IFS=" "
for i in $(echo "$TOOLBOX_TOOL_DIRS" | sed "s/,/ /g")
do
  _log DEBUG "Check if tool exists at path: ${i}/${TOOLBOX_TOOL}"
  if [[ -f "${i}/${TOOLBOX_TOOL}" ]]; then
    TOOLBOX_TOOL_PATH="${i}/${TOOLBOX_TOOL}"
    break
  fi
done
fi

if [[ -z ${TOOLBOX_TOOL_PATH} ]]; then
  _log ERROR "TOOLBOX_TOOL_PATH: ${TOOLBOX_TOOL_PATH} NOT FOUND!"
  exit 1
fi

_log DEBUG "TOOLBOX_TOOL_PATH=\"${TOOLBOX_TOOL_PATH}\""
_log TRACE "entrypoint.sh: Execute entrypoint in ${TOOLBOX_WRAP_ENTRYPOINT_MODE} mode"
_log TRACE "Env vars inside docker image:"
_log TRACE "$(env)"

case "$TOOLBOX_WRAP_ENTRYPOINT_MODE" in
  vars)
    echo "TOOLBOX_TOOL_PATH=\"${TOOLBOX_TOOL_PATH}\"";;
  run)
    shift

    toolbox_exec_hook "toolbox_docker_entrypoint_run" "before"

    _log DEBUG "Execute tool: ${TOOLBOX_TOOL_PATH} $*"
    ${TOOLBOX_TOOL_PATH} "$@"

    toolbox_exec_hook "toolbox_docker_entrypoint_run" "after"
    ;;
esac

