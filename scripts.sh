set -e
PROJECT_NAME="example-lambda"
CRON_EXECUTION_EXPRESSION="*/5 * * * ? *"

action=$1

if [ "$action" = "setup-infra" ]; then
    aws cloudformation create-stack \
        --stack-name "$PROJECT_NAME-stack" \
        --template-body file://cloudformation.yaml \
        --parameters ParameterKey=ProjectName,ParameterValue="$PROJECT_NAME" ParameterKey=CronExecutionExpression,ParameterValue="$CRON_EXECUTION_EXPRESSION" \
        --capabilities CAPABILITY_NAMED_IAM \
        | cat

elif [ "$action" = "update-infra" ]; then
    aws cloudformation update-stack \
        --stack-name "$PROJECT_NAME-stack" \
        --template-body file://cloudformation.yaml \
        --parameters ParameterKey=ProjectName,ParameterValue="$PROJECT_NAME" ParameterKey=CronExecutionExpression,ParameterValue="$CRON_EXECUTION_EXPRESSION" \
        --capabilities CAPABILITY_NAMED_IAM \
        | cat

elif [ "$action" = "delete-infra" ]; then
    aws cloudformation delete-stack \
        --stack-name "$PROJECT_NAME-stack" \
        | cat

elif [ "$action" = "package" ]; then
    filename=$2

    [ -z "$filename" ] && echo "second arg filename is required" && exit 1
    [ -f "$filename" ] && echo "package '$filename' alredy exists, aborting." && exit 1

    echo "creating package"

    # package dependencies
    poetry export --without-hashes --format=requirements.txt --output=requirements.txt
    pip install -r requirements.txt --target ./package
    cd ./package
    zip -r "../$filename" .
    cd ..

    # include app in the package
    zip -r $filename app

    # cleanup
    rm requirements.txt 
    rm -r package
    echo "$filename created successfully"

elif [ "$action" = "deploy" ]; then
    # get last commit hash
    commit=$(git log --oneline -1 | awk '{print $1}')
    filename="package_$commit.zip"

    sh scripts.sh package "$filename"

    aws lambda update-function-code \
        --function-name "$PROJECT_NAME" \
        --zip-file "fileb://$filename" \
        | cat

else 
    echo "action '$action' not found"
    exit 1
fi