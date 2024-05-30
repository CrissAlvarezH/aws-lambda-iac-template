set -e

action=$1

if [ "$action" = "setup-infra" ]; then
    aws cloudformation create-stack \
        --stack-name example-lambda-app \
        --template-body file://cloudformation.yaml \
        --capabilities CAPABILITY_NAMED_IAM \
        | cat

elif [ "$action" = "update-infra" ]; then
    aws cloudformation update-stack \
        --stack-name example-lambda-app \
        --template-body file://cloudformation.yaml \
        --capabilities CAPABILITY_NAMED_IAM \
        | cat

elif [ "$action" = "delete-infra" ]; then
    aws cloudformation delete-stack \
        --stack-name example-lambda-app \
        | cat

elif [ "$action" = "package" ]; then
    filename=$2

    [ -z "$filename" ] && echo "second arg filename is required" && exit 1
    [ -f "$filename" ] && echo "package '$filename' alredy exists, aborting." && exit 1

    echo "creating package.zip"
    zip -r "$filename" app
    echo "$filename created successfully"

elif [ "$action" = "deploy" ]; then
    # get last commit hash
    commit=$(git log --oneline -1 | awk '{print $1}')
    filename="package_$commit.zip"

    sh scripts.sh package "$filename"

    aws lambda update-function-code \
        --function-name lambda-example \
        --zip-file "fileb://$filename" \
        | cat
else 
    echo "action '$action' not found"
    exit 1
fi