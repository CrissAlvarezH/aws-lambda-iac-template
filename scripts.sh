set -e

function log() {
  GREEN='\033[0;32m'
  YELLOW="\033[0;33m"
  COLOR_OFF="\033[0m"

  if [ "$2" = "warn" ]; then
    color="$YELLOW"
  else
    color="$GREEN"
  fi

  printf "\n${color}$1${COLOR_OFF}\n"
}

function read_env_var() {
    name=$1
    echo "$(cat .env | grep $name | awk -F \= '{print $2}' | sed 's/"//g')"
}

PROJECT_NAME=$(read_env_var "PROJECT_NAME")
CRON_EXECUTION_EXPRESSION=$(read_env_var "CRON_EXECUTION_EXPRESSION")
TIMEOUT=$(read_env_var "TIMEOUT")

log "PROJECT_NAME=$PROJECT_NAME"
log "CRON_EXECUTION_EXPRESSION=$CRON_EXECUTION_EXPRESSION"
log "TIMEOUT=$TIMEOUT"

action=$1

function latest_commit() {
    echo "$(git log --oneline -1 | awk '{print $1}')"
}

if [ "$action" = "setup-infra" ]; then
    aws cloudformation create-stack \
        --stack-name "$PROJECT_NAME-stack" \
        --template-body file://cloudformation.yaml \
        --parameters \
            ParameterKey=ProjectName,ParameterValue="$PROJECT_NAME" \
            ParameterKey=CronExecutionExpression,ParameterValue="$CRON_EXECUTION_EXPRESSION" \
            ParameterKey=Timeout,ParameterValue="$TIMEOUT" \
        --capabilities CAPABILITY_NAMED_IAM \
        | cat

elif [ "$action" = "update-infra" ]; then
    aws cloudformation update-stack \
        --stack-name "$PROJECT_NAME-stack" \
        --template-body file://cloudformation.yaml \
        --parameters \
            ParameterKey=ProjectName,ParameterValue="$PROJECT_NAME" \
            ParameterKey=CronExecutionExpression,ParameterValue="$CRON_EXECUTION_EXPRESSION" \
            ParameterKey=Timeout,ParameterValue="$TIMEOUT" \
        --capabilities CAPABILITY_NAMED_IAM \
        | cat

elif [ "$action" = "delete-infra" ]; then
    aws cloudformation delete-stack \
        --stack-name "$PROJECT_NAME-stack" \
        | cat

elif [ "$action" = "package" ]; then
    filename=$2

    [ -z "$filename" ] && log "second arg filename is required" "warn" && exit 1
    [ -f "$filename" ] && log "package '$filename' alredy exists, aborting." "warn" && exit 1

    log "packaging dependencies"
    poetry export --without-hashes --format=requirements.txt --output=requirements.txt
    pip install -r requirements.txt --target ./package
    cd ./package
    zip -r "../$filename" .
    cd ..

    log "including code app to package"
    zip -r $filename app

    # cleanup
    rm requirements.txt 
    rm -r package

    log "$filename created successfully"

elif [ "$action" = "deploy" ]; then
    commit=$(latest_commit)
    filename="package_$commit.zip"

    sh scripts.sh package "$filename"

    log "updating lambda code"

    aws lambda update-function-code \
        --function-name "$PROJECT_NAME" \
        --zip-file "fileb://$filename" \
        | cat

    # wait lambda code finish update process before 
    # go to publishing version step, because can raise an
    # exception: "An update is in progress for resource"
    sleep 3

    log "publishing new lambda version"
    
    aws lambda publish-version \
        --function-name "$PROJECT_NAME" \
        --description "commit: $commit" \
        | cat

    log "updating lambda PROD alias"

    aws lambda update-alias \
        --function-name "$PROJECT_NAME" \
        --function-version "\$LATEST" \
        --description "commit: $commit" \
        --name "prod" \
        | cat

    log "deploy finished"

else 
    log "action '$action' not found" "warn"
    exit 1
fi
