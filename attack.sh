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

REPORT="$TEMP_DIR/vegeta-results-$ATTACK_NAME-$(date +%Y%m%d%H%M%S)-$ATTACK_POD.bin"

function log() {
    echo "$(date +%Y%m%d%H%M%S) - $1"
}

function copy_report() {
    log "Copying $REPORT to $S3_BUCKET_NAME bucket"
    aws s3 cp "$REPORT" "s3://$S3_BUCKET_NAME"
    local rc=$?
    rm $REPORT
    exit $rc
}

trap copy_report INT TERM

log "Running vegeta"
echo "$COMMAND" | vegeta attack -rate="$RATE" -duration="$DURATION" > "$REPORT"

copy_report
