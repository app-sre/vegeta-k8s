#!/bin/bash

count=0
for var in AWS_ACCESS_KEY_ID \
           AWS_SECRET_ACCESS_KEY \
           AWS_DEFAULT_REGION \
           S3_BUCKET_NAME \
           TEMP_DIR \
           ATTACK_NAME \
           ATTACK_POD \
           COMMAND \
           DURATION \
           RATE
do
    if [[ ! "${!var}" ]]; then
        echo "$var not defined"
        count=$((count + 1))
    fi
done

[[ $count -gt 0 ]] && exit 1

VEGETA_RESULT="$TEMP_DIR/vegeta-results-$ATTACK_NAME-$(date +%Y%m%d%H%M%S)-$ATTACK_POD.bin"

function log() {
    echo "$(date +%Y%m%d%H%M%S) - $1"
}

function copy_report() {
    log "Copying $VEGETA_RESULT to $S3_BUCKET_NAME bucket"
    aws s3 cp "$VEGETA_RESULT" "s3://$S3_BUCKET_NAME"
    local rc=$?
    rm $VEGETA_RESULT
    exit $rc
}

trap copy_report INT TERM

log "Running vegeta"
echo "$COMMAND" | vegeta attack -name "$ATTACK_POD"  -rate="$RATE" -duration="$DURATION" > "$VEGETA_RESULT"
vegeta report $VEGETA_RESULT
copy_report
