
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

elif [ "$action" = "package" ]; then
    zip package.zip index.py

elif [ "$action" = "deploy" ]; then
    echo "creating 'package.zip'"
    sh scripts.sh package

    aws lambda update-function-code \
        --function-name lambda-example \
        --zip-file fileb://package.zip \
        | cat
else 
    echo "action '$action' not found"
    exit 1
fi