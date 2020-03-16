#!/usr/bin/env bash

function toolbox_wrap_exec() {
  _log TRACE "Start 'toolbox_wrap_exec' function with args: $*"

  TOOLBOX_DOCKER_SKIP=${TOOLBOX_DOCKER_SKIP:-false}

  if [ -f /.dockerenv ]; then
    echo "Inside docker already, setting TOOLBOX_DOCKER_SKIP to true"
    TOOLBOX_DOCKER_SKIP=true
  fi

  if [ ! "${TOOLBOX_DOCKER_SKIP}" == "true" ]; then
    _toolbox_wrap_prepare_env_vars "${1}"
  fi

  toolbox_docker_exec "$@"

  _log TRACE "End 'toolbox_wrap_exec' function"
}

function _toolbox_wrap_prepare_env_vars() {
  _log TRACE "Start '_toolbox_wrap_prepare_env_vars' function with args: $*"

  toolbox_docker_add_env_var_file_from_prefix "TOOLBOX_"

  local generated_env_file
  generated_env_file="$(_toolbox_wrap_generate_env_vars_file "$@")"
  TOOLBOX_TOOL_PATH=$(toolbox_util_read_var_from_env_file TOOLBOX_TOOL_PATH "${generated_env_file}")
  toolbox_docker_add_env_var_file "${generated_env_file}" "Variables generated from the variant command"

  toolbox_docker_add_env_var_file "${TOOLBOX_TOOL_PATH}.env"

  _log TRACE "End '_toolbox_wrap_prepare_env_vars' function"
}

# Provide file with env variables generated from the tool
function _toolbox_wrap_generate_env_vars_file() {
  _log TRACE "Start '_toolbox_wrap_generate_env_vars_file' function with args: $*"
  local generated_env_file
  local env_vars
  generated_env_file="$(mktemp)"
  env_vars=$(
    TOOLBOX_WRAP_ENTRYPOINT_MODE="vars" \
    TOOLBOX_DOCKER_ENV_VARS="-e TOOLBOX_WRAP_ENTRYPOINT_MODE" \
    TOOLBOX_DOCKER_RUN_EXEC_METHOD="toolbox_run" \
    TOOLBOX_EXEC_LOG_LEVEL_TITLE="DEBUG" \
    TOOLBOX_EXEC_LOG_LEVEL_CMD="DEBUG" \
    toolbox_docker_exec)
  echo "${env_vars}" > "${generated_env_file}"

  _log TRACE "End '_toolbox_wrap_generate_env_vars_file' function with args: $*"
  echo "${generated_env_file}"
}
