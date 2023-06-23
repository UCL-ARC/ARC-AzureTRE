#!/bin/bash
set -e

function api_is_ok(){
  
  echo "Calling /health endpoint..."
  response_code=$(curl --insecure --silent --max-time 5 --output "$api_response_file" --write-out "%{http_code}" "${TRE_URL}/api/health")

  if [[ "$response_code" != "200" ]]; then
    echo "*** ⚠️ API _not_ healthy ***"
    echo "Non-success code returned: $response_code"
    echo "Response:"
    cat "$api_response_file"
    return 1
  fi

  not_ok_count=$(jq -r '[.services | .[] | select(.status!="OK")] | length' < "$api_response_file")

  if [[ "$not_ok_count" == "0" ]]; then
    echo "*** ✅ API healthy ***"
    return 0
  else
    echo "*** ⚠️ API _not_ healthy ***"
    echo "Unhealthy services:"
    jq -r '[.services | .[] | select(.status!="OK")]' < "$api_response_file"
    return 1
  fi
}

# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Create a .gitignore'd  directory for temp output
mkdir -p "$DIR/script_tmp"
echo '*' > "$DIR/script_tmp/.gitignore"

api_response_file="$DIR/script_tmp/api_response.txt"
touch "$api_response_file"

# Add retries in case the backends aren't up yet
retries_left=5
while ! api_is_ok; do
  retries_left=$(( retries_left - 1))

  if [ $retries_left -eq 0 ]; then
    echo "Ran out of retries"
    break
  fi

  echo "Waiting..."
  sleep 30
done
