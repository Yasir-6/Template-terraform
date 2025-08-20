
# Docker container image
container_image = "211125510898.dkr.ecr.us-east-2.amazonaws.com/hutch_ecr_repo:latest"

# Port on which the container listens
container_port = 8080

# List of environment variables (comma-delimited)
# env_variable_names = ["ENV_VAR1", "ENV_VAR2"]

# Desired count of ECS tasks
desired_count = 1

# CPU value for ECS Task
cpu = "256"

# Memory value for ECS Task
memory = "512"

# Whether to use private subnets for ECS tasks
use_private_subnets = true

# Whether to enable Auto Scaling
enable_auto_scaling = false

# env file ARN which is in s3 bucket "env-file-for-ecs-backend-deployment"
env_file_arn = "arn:aws:s3:::env-file-for-ecs-backend-deployment/.env"

