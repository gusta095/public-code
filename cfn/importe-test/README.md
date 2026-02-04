# Importe SQS

# 1. Criar a old-stack com Retain
aws cloudformation deploy \
  --stack-name old-stack \
  --template-file old-stack.yaml

# 2. Deletar a old-stack e esperar
aws cloudformation delete-stack --stack-name old-stack
aws cloudformation wait stack-delete-complete --stack-name old-stack

# 3. Criar change set de import
aws cloudformation create-change-set \
  --stack-name new-stack \
  --change-set-name import-sqs-final \
  --change-set-type IMPORT \
  --resources-to-import file://resources-to-import.json \
  --template-body file://new-stack.yaml

# 4. Mostra o status do change set de import
aws cloudformation describe-change-set \
  --stack-name new-stack \
  --change-set-name import-sqs

# 5. Executar o import
aws cloudformation execute-change-set \
  --stack-name new-stack \
  --change-set-name import-sqs-final
