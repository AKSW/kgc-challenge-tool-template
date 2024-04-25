#!/bin/bash

# install all templates into the challenge folders

set -eu
set -o pipefail

if [[ $# -lt 1 ]]; then
    echo "Syntax: $0 <toolname>" >&2
    exit 1
fi

toolname="$1"
metadata_file="${toolname}.json"
template_file="${toolname}.template.yml"

script_dir="$(dirname "$(readlink -f "$0")")"

# assume this script is placed in challenge-tool/templates
cd "$script_dir/../"
cd "downloads/eswc-kgc-challenge-2024/"
challenge_root="$(pwd)"

for script in "$script_dir"/*/config.sh; do
    target_root_folders=()
    get_mappingfile() { echo "please define get_mappingfile() in ${script}" >&2; exit 1; }

    parent="$(basename "$(dirname "$script")")"
    if [[ ! -f "$script_dir/$parent/$template_file" ]]; then
	continue
    fi

    echo "::: $parent"
    . "$script"


    for target_root_folder in "${target_root_folders[@]}"; do
        for dir in $target_root_folder/*; do
            if [[ ! -d "$dir" ]]; then
                continue
            fi

            echo "=> $dir"
            name="$dir"
        
            name2="${name//_/ }"
            name2="${name2//\// \/ }"

            mappingfile="$(get_mappingfile "$name")"

            NAME="$name" \
            NAME2="$name2" \
            TOOLNAME="${toolname}" \
            TOOLRESOURCE="Rpt" \
            MAPPINGFILE="$mappingfile" \
            envsubst '$NAME$NAME2$TOOLNAME$TOOLRESOURCE$MAPPINGFILE' \
            < "$script_dir/$parent/$template_file" \
            | "$script_dir/convert.py" \
            > "$dir/$metadata_file"
        done
    done
done

