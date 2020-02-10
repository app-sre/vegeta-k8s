#!/bin/bash

count=0
for var in AWS_ACCESS_KEY_ID \
           AWS_SECRET_ACCESS_KEY \
           AWS_DEFAULT_REGION \
           S3_BUCKET_NAME \
           TEMP_DIR \
           ATTACK_NAME \
           ATTACK_POD \
           DURATION \
           TARGETS \
           RATE
do
    if [[ ! "${!var}" ]]; then
        echo "$var not defined"
        count=$((count + 1))
    fi
done

ULIMIT=${ULIMIT:-1048576}
ulimit -n $ULIMIT

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

CMD="vegeta attack -targets=$TARGETS -name=$ATTACK_POD  -rate=$RATE -duration=$DURATION"
[ -n "$KEEPALIVE" ] && CMD="$CMD -keepalive=$KEEPALIVE"
[ -n "$MAX_WORKERS" ] && CMD="$CMD -max-workers=$MAX_WORKERS"
[ -n "$MAX_CONNECTIONS" ] && CMD="$CMD -max-connections=$MAX_CONNECTIONS"
[ -n "$CONNECTIONS" ] && CMD="$CMD -connections=$CONNECTIONS"
[ -n "$TIMEOUT" ] && CMD="$CMD -timeout=$TIMEOUT"

log "Running $CMD"
$CMD > "$VEGETA_RESULT"

vegeta report $VEGETA_RESULT
copy_report
