# teste

sed -i '/"Type":[[:space:]]*"AWS::ApiGateway::/{
s/^\([[:space:]]*\).*/\1"DeletionPolicy": "Retain",\
&/
}' api-gateway.json
