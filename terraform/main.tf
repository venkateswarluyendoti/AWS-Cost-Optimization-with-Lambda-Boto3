provider "aws" {
  region = "us-east-1"  # Adjust to your region
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "cost-optimization-ebs-snapshot-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Policy for EBS Operations
resource "aws_iam_role_policy" "ebs_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["ec2:DescribeSnapshots", "ec2:DeleteSnapshot", "ec2:DescribeVolumes", "ec2:DescribeInstances"]
      Effect = "Allow"
      Resource = "*"
    }]
  })
}

# Lambda Function
resource "aws_lambda_function" "cost_optimization" {
  function_name = "cost-optimization-ebs-snapshot"
  role          = aws_iam_role.lambda_role.arn
  handler       = "snapshot_cleaner.lambda_handler"
  runtime       = "python3.10"
  timeout       = 10
  filename      = "./snapshot_cleaner.py"  # Must be in terraform/ directory
  source_code_hash = filebase64sha256("./snapshot_cleaner.py")
}

# EventBridge Trigger (Daily)
resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "daily-snapshot-cleanup"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "lambda"
  arn       = aws_lambda_function.cost_optimization.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_optimization.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}