# Importe SQS v2

# Criação dos recursos
aws cloudformation get-template \
  --stack-name old-stack \
  --query TemplateBody \
  --output text > template.yaml

# Remoção da stack
yq 'del(.Resources.OldQueue1, .Resources.OldQueue2)' template.yaml > new.yaml

# Atualização da stack
aws cloudformation deploy \
  --stack-name old-stack \
  --template-file new.yaml