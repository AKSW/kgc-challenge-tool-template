#!/bin/bash

# install all templates into the challenge folders

set -eu
set -o pipefail

if [[ $# -lt 1 ]]; then
    echo "Syntax: $0 <toolname>" >&2
    exit 1
fi

__toolname="$1"
__metadata_file="${__toolname}.json"
__template_file="${__toolname}.template.yml"

__script_dir="$(dirname "$(readlink -f "$0")")"

# assume this script is placed in challenge-tool/templates
#cd "$__script_dir/../"
cd "downloads/eswc-kgc-challenge-2024/"
challenge_root="$(pwd)"

for __script in "$__script_dir"/*/config.sh; do
    target_root_folders=()
    expect_failure=()

    # custom attribute default implementations
    get_mappingfile() { echo "please define get_mappingfile() in ${__script}" >&2; exit 1; }
    get_expect_failure() { return; }

    __parent="$(basename "$(dirname "$__script")")"
    if [[ ! -f "$__script_dir/$__parent/$__template_file" ]]; then
        continue
    fi

    echo "::: $__parent"
    . "$__script"


    for __target_root_folder in "${target_root_folders[@]}"; do
        for __dir in $__target_root_folder/*; do
            if [[ ! -d "$__dir" ]]; then
                continue
            fi

            echo "=> $__dir"
            __name="$__dir"
        
            __name2="${__name//_/ }"
            __name2="${__name2//\// \/ }"

            __mappingfile="$(get_mappingfile "$__name")"
            __expect_failure="$(get_expect_failure "$__name")"

            NAME="$__name" \
            NAME2="$__name2" \
            TOOLNAME="${__toolname}" \
            TOOLRESOURCE="Rpt" \
            MAPPINGFILE="$__mappingfile" \
            EXPECT_FAILURE="$__expect_failure" \
            envsubst '$NAME$NAME2$TOOLNAME$TOOLRESOURCE$MAPPINGFILE$EXPECT_FAILURE' \
            < "$__script_dir/$__parent/$__template_file" \
            | "$__script_dir/convert.py" \
            > "$__dir/$__metadata_file"
        done
    done
done

