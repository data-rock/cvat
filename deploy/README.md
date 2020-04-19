### What is this for
This is cloudformation to deploy the CVAT labeling tool into ECS

Apart from the normal ECS, it also creates the following AWS resources:
  - RDS(`Postgres`)
  - Elasticache(`Redis`)
  - EFS
  - ECR
  - Cloudwatch for ECS ASGs

Stack names:
  - `cvat-test` for test
  - `cvat-prod` for prod

### Why not fargate
The app requires shared folders to store the image. By the time we build the solution, AWS hadn't released

the support the EFS in Fargate. However, as of 18th Jan 2020, they released the preview support of EFS in

Fargate(https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_EFSVolumeConfiguration.html)

We should consider move to Fargate when this feature is released.

### Architect diagram
![](./img/aws_diagram.png)

### Notes
Only deploy `deploy` branch

### Production super user credentials

You can find the credentials in AWS Parameter Store
  - `/datarock/cvat/superuser/username`
  - `/datarock/cvat/superuser/password`

### Before first deployment
  - Create Keypairs
    - `ecs-keypair` for test
    - `ecs-prod-keypair` for prod
  - SSM parameters
    ```
    aws ssm put-parameter --name "/datarock/cvat/dbpassword" --value "verygoodpasswordhere" --type "String" --overwrite
    ```
  - Run
    ```
    deploy/bin/run-before-first-deploy.sh
    ```
  - Change the EFS permissions

### How to deploy
  ```
  deploy/bin/deploy.sh
  ```
  Or, go to `CircleCI` [Pipelines](https://app.circleci.com/github/data-rock/cvat/pipelines) to deploy to the

  correct environment

### Admin panel
For Production goto
  - https://label-api.prod.datarock.com.au/admin
For Test goto
  - https://label-api.test.datarock.com.au/admin

### API
For Production goto
  - https://label-api.prod.datarock.com.au/api/swagger
For Test goto
  - https://label-api.test.datarock.com.au/api/swagger
