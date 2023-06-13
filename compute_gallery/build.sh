#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
IFS=$'\n'  # split on newlines

template_names=$(yq -r '.[].template_name' "${SCRIPT_DIR}/images.yml")

echo "Building images. This will take 1h+"
for template_name in $template_names; do
    echo "Building ${template_name}"
    (
        az resource invoke-action \
            --resource-group "rg-cg-${TF_VAR_tre_id}" \
            --resource-type  Microsoft.VirtualMachineImages/imageTemplates \
            --name "$template_name" \
            --action Run
    ) &  # Execute in the background
done

wait  # for all builds to finish
