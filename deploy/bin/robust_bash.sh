#!/bin/bash -eu

function error {
  echo "ERROR: ${1:-}"
}

# Check to see that we have a required binary on the path
function require_binary {
  if [ -z "${1:-}" ]; then
    error "${FUNCNAME[0]} requires an argument"
    exit 1
  fi

  if ! [ -x "$(command -v "$1")" ]; then
    error "The required executable '$1' is not on the path."
    exit 1
  fi
}

function require_env_var {
  var_name="${1:-}"
  if [ -z "${!var_name:-}" ]; then
    error "The required environment variable ${var_name} is empty"
    exit 1
  fi
}
