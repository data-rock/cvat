### What is this for
This is cloudformation to deploy the CVAT labeling tool into ECS

### Notes
Only deploy `deploy` branch

### Before deployment
- Keypairs
- SSM parameters
```
aws ssm put-parameter --name "/datarock/cvat/dbpassword" --value "verygoodpasswordhere" --type "String" --overwrite
```

### How to deploy
```
deploy/bin/deploy.sh
```