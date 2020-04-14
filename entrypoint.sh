#!/usr/bin/env bash

# shellcheck disable=SC1090
# shellcheck disable=SC1091

# Set strict bash mode
set -euo pipefail

. "${TOOLBOX_DEPS_DIR}"/toolbox-utils/includes/log.sh
. "${TOOLBOX_DEPS_DIR}"/toolbox-utils/includes/util.sh
. "${TOOLBOX_DEPS_DIR}"/toolbox-exec/includes/exec.sh

TOOLBOX_TOOL=${TOOLBOX_TOOL:-${1}}
TOOLBOX_TOOL_PATH=${TOOLBOX_TOOL_PATH:-}
TOOLBOX_TOOL_DIRS=${TOOLBOX_TOOL_DIRS:-toolbox}
TOOLBOX_WRAP_ENTRYPOINT_MODE=${TOOLBOX_WRAP_ENTRYPOINT_MODE:-run}

_log TRACE "entrypoint.sh: Inside docker (aroq/toolbox-wrap)"
_log DEBUG "TOOLBOX_TOOL: ${TOOLBOX_TOOL}"
_log DEBUG "TOOLBOX_TOOL_DIRS: ${TOOLBOX_TOOL_DIRS}"


TOOLBOX_TOOL_PATH=$(toolbox_exec_find_tool "${TOOLBOX_TOOL}" "${TOOLBOX_TOOL_PATH}")
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
