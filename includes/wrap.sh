#!/usr/bin/env bash

function toolbox_wrap_exec_tool_in_docker {
  _log TRACE "Start 'toolbox_wrap_exec_tool_in_docker' function"
  local _cmd="$1"

  TOOLBOX_DOCKER_RUN_TOOL_ENV_FILE=${TOOLBOX_DOCKER_RUN_TOOL_ENV_FILE:-}
  if [[ -f "${_cmd}.env" ]]; then
    TOOLBOX_DOCKER_RUN_TOOL_ENV_FILE="${TOOLBOX_DOCKER_RUN_TOOL_ENV_FILE} --env-file=${_cmd}.env"
    _log DEBUG "${YELLOW}Variable list from tool - ${_cmd}.env:${RESTORE}"
    _log DEBUG "$(cat "${_cmd}".env)"
  fi

  # Provide TOOLBOX_* environment variables file
  local toolbox_env_file
  toolbox_env_file="$(mktemp)"
  (env | grep ^TOOLBOX_) >> "${toolbox_env_file}"
  _log DEBUG "${YELLOW}'TOOLBOX_*' variable list - ${toolbox_env_file}:${RESTORE}"
  _log DEBUG "${LYELLOW}$(cat "${toolbox_env_file}")${RESTORE}"
  _log DEBUG "${YELLOW}---${RESTORE}"

  TOOLBOX_DOCKER_RUN_TOOL_ENV_FILE="${TOOLBOX_DOCKER_RUN_TOOL_ENV_FILE} --env-file=${toolbox_env_file}"
  TOOLBOX_DOCKER_ENTRYPOINT="${_cmd}"

  shift

  toolbox_docker_exec "$@"
}

function toolbox_wrap_exec_tool() {
  _log TRACE "Start 'toolbox_wrap_exec_tool' function"
  TOOLBOX_RUN=${TOOLBOX_RUN:-false}
  TOOLBOX_DOCKER_SKIP=${TOOLBOX_DOCKER_SKIP:-false}
  # Decide about Docker mode
  if [ "${TOOLBOX_RUN}" == "false" ] && [ "${TOOLBOX_DOCKER_SKIP}" == "false" ]; then
    if [ -f /.dockerenv ]; then
      echo "Inside docker already, setting TOOLBOX_DOCKER_SKIP to true"
      TOOLBOX_DOCKER_SKIP=true
    fi
  fi

  local _tool_path
  _tool_path=$(toolbox_wrap_detect_tool_path "${1}")

  if [ -z "${_tool_path}" ]; then
    echo "Tool ${1} is not found"
  else
    TOOLBOX_RUN=true
    # Remove the first argument
    shift
    toolbox_wrap_exec_tool_in_docker "${_tool_path}" "$@"
  fi
  _log TRACE "End 'toolbox_wrap_exec_tool' function"
}

function toolbox_wrap_detect_tool_path {
  _log TRACE "Start 'toolbox_wrap_detect_tool_path' function"
  TOOL_PATH=${TOOL_PATH:-}
  CMD=${1:-}

  _log DEBUG "_detect_tool_path: TOOL_PATH: ${TOOL_PATH}"
  _log DEBUG "_detect_tool_path: TOOLBOX_TOOL_DIRS: ${TOOLBOX_TOOL_DIRS}"

  if [ ! -f "${TOOL_PATH}" ]; then
    # Find tool path
    IFS=" "
    for i in $(echo "$TOOLBOX_TOOL_DIRS" | sed "s/,/ /g")
    do
      _log DEBUG "Check if tool exists: $i/${CMD}"
      if [[ -f "${i}/${CMD}" ]]; then
        TOOL_PATH="${i}/${CMD}"
        break
      fi
    done
  fi

  _log DEBUG "_detect_tool_path: TOOL_PATH: ${TOOL_PATH}"
  _log TRACE "End 'toolbox_wrap_detect_tool_path' function"

  echo "${TOOL_PATH}"
}
