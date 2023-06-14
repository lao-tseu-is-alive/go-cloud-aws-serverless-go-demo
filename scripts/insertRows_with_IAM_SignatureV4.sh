
#######################################################
# script    : insertRows_with_IAM_SignatureV4.sh
# purpose   : insert two new rows using a curl call to the Gateway API
#             when the PUT route was secured with IAM authorization
# comment   : after securing endpoint with IAM authorization we must provide a request with Signature Version 4
#             https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-access-control-iam.html
#             as explained here : https://docs.aws.amazon.com/IAM/latest/UserGuide/create-signed-request.html
#             but thanks to curl (since V.7.75) we can use the AWS v4 signature directly like this
#######################################################
[[ -n "${AWS_ACCESS_KEY_ID}" ]]     || { echo "AWS_ACCESS_KEY_ID env variable is required" >&2; exit 1; }
[[ -n "${AWS_SECRET_ACCESS_KEY}" ]] || { echo "AWS_SECRET_ACCESS_KEY env variable is required" >&2; exit 1; }

ApiEndpoint=$(aws apigatewayv2 get-apis |jq -r '.Items[] | select(.Name == "serverless-go-demo") | .ApiEndpoint')
cmdCurl=(curl -s -X PUT -H 'Content-Type: application/json')
cmdCurl+=(--user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" --aws-sigv4 'aws:amz:us-east-1:execute-api')
NewID01=$(python3 -c 'import uuid;print(uuid.uuid4())')
echo "## About to insert new item in ${ApiEndpoint} with id:${NewID01}"
Product01="{\"id\": \"$NewID01\" ,\"name\": \"Red Sunglasses\"  ,\"price\": 181.70}"
# expand the array, run the command
"${cmdCurl[@]}" -d "$Product01" "$ApiEndpoint/$NewID01"
echo " --"
NewID02=$(python3 -c 'import uuid;print(uuid.uuid4())')
echo "## About to insert new item in ${ApiEndpoint} with id:${NewID02}"
Product02="{\"id\": \"$NewID02\" ,\"name\": \"Big Yellow Submarine\"  ,\"price\": 871488.05}"
"${cmdCurl[@]}"  -d "$Product02" "$ApiEndpoint/$NewID02"
echo " --"
echo "## List of products running : curl -s -H 'Content-Type: application/json' $ApiEndpoint/"
curl -s -H 'Content-Type: application/json' "$ApiEndpoint/" |jq