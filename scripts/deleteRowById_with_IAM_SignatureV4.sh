#######################################################
# script    : deleteRowById_with_IAM_SignatureV4.sh
# purpose   : remove a row with a given id using a curl call to the Gateway API
#             when the DELETE route was secured with IAM authorization
# comment   : after securing endpoint with IAM authorization we must provide a request with Signature Version 4
#             https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-access-control-iam.html
#             as explained here : https://docs.aws.amazon.com/IAM/latest/UserGuide/create-signed-request.html
#             but thanks to curl (since V.7.75) we can use the AWS v4 signature directly like this
#######################################################
[ $# -eq 1 ]     || { echo "expecting first parameter with DynamoDB ID to delete" >&2; exit 1; }
[[ -n "${AWS_ACCESS_KEY_ID}" ]]     || { echo "AWS_ACCESS_KEY_ID env variable is required" >&2; exit 1; }
[[ -n "${AWS_SECRET_ACCESS_KEY}" ]] || { echo "AWS_SECRET_ACCESS_KEY env variable is required" >&2; exit 1; }
ApiEndpoint=$(aws apigatewayv2 get-apis |jq -r '.Items[] | select(.Name == "serverless-go-demo") | .ApiEndpoint')
cmdCurl=(curl -s -X DELETE -H 'Content-Type: application/json')
cmdCurl+=(--user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" --aws-sigv4 'aws:amz:us-east-1:execute-api')
ID=$1
echo "## About to delete item in ${ApiEndpoint} with id:${ID}"
# expand the array, run the command  -d "{\"id\": \"$ID\"}"
"${cmdCurl[@]}"  "$ApiEndpoint/$ID"
echo " -- "
echo "## List of remaining products running obtained with: curl -s -H 'Content-Type: application/json' $ApiEndpoint/"
curl -s -H 'Content-Type: application/json' "$ApiEndpoint/" | jq