# bash config

## folders where to install metadata.json
target_root_folders=(
    "track1/rml-core"
)

get_mappingfile() {
    echo "mapping.ttl"
}

## cases where failure is expected
expect_failure=(
    "RMLTC0002c-*"  # non-existant column in mapping

    "RMLTC0002e-*"  # non-existant column in mapping
    "RMLTC0002f-*"  # wrongly quoted column names in mapping)
    "RMLTC0002g-*"  # non-existant column in mapping
    "RMLTC0002h-*"  # non-existant column in mapping
    "RMLTC0002i-*"  # non-existant column in mapping
    "RMLTC0002j-*"  # non-existant column in mapping

    "RMLTC0003a-*"  # non-existant column in mapping

    "RMLTC0004b-*"  # rr:termType rr:Literal on rr:subjectMap

    "RMLTC0007h-*"  # rml:termType rml:Literal in rml:graphMap (the test case also contains invalid column reference...)

    "RMLTC0012c-*"  # TriplesMap without subjectMap
    "RMLTC0012d-*"  # TriplesMap with two subjectMap

    "RMLTC0015b-*"  # invalid language tag

    "RMLTC0019b-*"  # white space in IRI column
)

get_expect_failure() {
    local name="$1"
    for is_fail in "${expect_failure[@]}"; do
        if [[ "$name" = */$is_fail ]]; then
            echo true
            return
        fi
    done
    echo false
    return
}
