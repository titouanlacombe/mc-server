#!/usr/bin/env bash

set -e

ENV_DEFAULT="default.env"
ENV_FILE=".env"

if [[ ! -f "$ENV_DEFAULT" ]]; then
    echo "$ENV_DEFAULT file not found!"
    exit 1
fi

parse_env() {
  local -n temp_env=$1
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    temp_env["$key"]="$value"
  done < "$2"
}

declare -A default_env
parse_env default_env default.env "$ENV_DEFAULT"

declare -A env
if [[ -f "$ENV_FILE" ]]; then
  parse_env env .env "$ENV_FILE"
fi

missing_vars=()
for key in "${!default_env[@]}"; do
    if [[ -z "${env[$key]+isset}" ]]; then
        missing_vars+=("$key")
    fi
done

if [[ ${#missing_vars[@]} -eq 0 ]]; then
    exit 0
fi

echo "Please provide the missing values to the $ENV_FILE file:"
for key in "${missing_vars[@]}"; do
    default_value="${default_env[$key]}"
    read -rp "$key [$default_value]: " user_input
    env["$key"]="${user_input:-$default_value}"
done

# Write .env file
> "$ENV_FILE"
for key in "${!env[@]}"; do
    echo "$key=${env[$key]}" >> "$ENV_FILE"
done

echo "$ENV_FILE updated!"
