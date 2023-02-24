############################### Lambda role ###############################
resource "aws_iam_role" "lambda_iam_role" {
  name               = "lambda-iam-role-${var.env}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

############################### EC2 Network ###############################
resource "aws_iam_policy" "ec2_lamdbda_handler_policy" {
  name   = "ec2-lamdbda-handler-policy-${var.env}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AssignPrivateIpAddresses",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:UnassignPrivateIpAddresses"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_role_policy_lambda_ec2" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.ec2_lamdbda_handler_policy.arn
  depends_on = [
    aws_iam_role.lambda_iam_role,
    aws_iam_policy.ec2_lamdbda_handler_policy,
  ]
}

############################### Logs ###############################
resource "aws_iam_policy" "logs_lamdbda_handler_policy" {
  name   = "logs-lamdbda-handler-policy-${var.env}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_role_policy_lambda_logs" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.logs_lamdbda_handler_policy.arn
  depends_on = [
    aws_iam_role.lambda_iam_role,
    aws_iam_policy.logs_lamdbda_handler_policy,
  ]
}

############################### ECR ###############################
resource "aws_iam_policy" "ecr_lamdbda_handler_policy" {
  name   = "ecr-lamdbda-handler-policy-${var.env}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_role_policy_lambda_ecr" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.ecr_lamdbda_handler_policy.arn
  depends_on = [
    aws_iam_role.lambda_iam_role,
    aws_iam_policy.ecr_lamdbda_handler_policy,
  ]
}

############################### DynamoDB ###############################
resource "aws_iam_policy" "dynamodb_lamdbda_handler_policy" {
  name   = "dynamodb-lamdbda-handler-policy-${var.env}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.users_tbl.arn}"
    }
  ]
}
EOF
  depends_on = [
    aws_dynamodb_table.users_tbl,
  ]
}

resource "aws_iam_role_policy_attachment" "attach_role_policy_lambda_dynamodb" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.dynamodb_lamdbda_handler_policy.arn
  depends_on = [
    aws_iam_role.lambda_iam_role,
    aws_iam_policy.dynamodb_lamdbda_handler_policy,
  ]
}

############################### KMS ###############################
resource "aws_iam_policy" "kms_lamdbda_handler_policy" {
  name   = "kms-lamdbda-handler-policy-${var.env}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.customer_key.arn}"
    }
  ]
}
EOF
  depends_on = [
    aws_kms_key.customer_key,
  ]
}

resource "aws_iam_role_policy_attachment" "attach_role_policy_lambda_kms" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.kms_lamdbda_handler_policy.arn
  depends_on = [
    aws_iam_role.lambda_iam_role,
    aws_iam_policy.kms_lamdbda_handler_policy,
  ]
}

############################### SSM ###############################
resource "aws_iam_policy" "ssm_lamdbda_handler_policy" {
  name   = "ssm-lamdbda-handler-policy-${var.env}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParameter"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/lambda/${var.env}/jwt-secret"
    }
  ]
}
EOF
  depends_on = [
    aws_ssm_parameter.lambda_jwt_secret,
  ]
}

resource "aws_iam_role_policy_attachment" "attach_role_policy_lambda_ssm" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.ssm_lamdbda_handler_policy.arn
  depends_on = [
    aws_iam_role.lambda_iam_role,
    aws_iam_policy.ssm_lamdbda_handler_policy,
  ]
}

############################### API GW Invocation  ###############################
resource "aws_iam_role" "lambda_iam_invocation_api_gw_role" {
  name               = "lambda-iam-invocation-api-gw-role-${var.env}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_iam_invocation_api_gw_policy" {
  name   = "lambda-iam-invocation-api-gw-policy-${var.env}"
  role   = aws_iam_role.lambda_iam_invocation_api_gw_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.lambda_function_authorizer.arn}"
    }
  ]
}
EOF
  depends_on = [
    aws_iam_role.lambda_iam_invocation_api_gw_role,
    aws_lambda_function.lambda_function_authorizer,
  ]
}

############################### EC2 role ###############################
resource "aws_iam_role" "ec2_role" {
  name               = "ec2-role-ecs-${var.env}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": ["ec2.amazonaws.com"]
    },
    "Action": "sts:AssumeRole",
    "Sid": ""
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_ec2_role_amazon_ec2_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_ec2_role_amazon_ecs_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# policy to allow interaction using SSM with the instance
resource "aws_iam_role_policy_attachment" "attach_ec2_role_amazon_ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################### ECS role ###############################
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "AmazonECSTaskExecutionRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": ["ecs-tasks.amazonaws.com"]
    },
    "Effect": "Allow",
    "Sid": ""
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_AmazonECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "attach_AmazonECS_FullAccess" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}
