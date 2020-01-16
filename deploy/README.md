### What is this for
This is cloudformation to deploy the CVAT labeling tool into ECS

### Notes
Only deploy `deploy` branch

### Before first deployment
- Create Keypairs
  `ecs-keypair` for test
  `ecs-prod-keypair` for prod
- SSM parameters
```
aws ssm put-parameter --name "/datarock/cvat/dbpassword" --value "verygoodpasswordhere" --type "String" --overwrite
```
- Run
```
deploy/bin/run-before-first-deploy.sh
```

### How to deploy
```
deploy/bin/deploy.sh
```