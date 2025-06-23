resource "aws_iam_role" "lambda_role" {
  name               = "Lambda_Function_Role"
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

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}


resource "aws_lambda_function" "terraform_lambda_func" {
  filename      = "lambda_function.zip"
  function_name = "list_s3_buckets"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_handler.py"
  runtime       = "python3.12"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]

  tags = {
    "lambda-console:blueprint" = "hello-world"
  }

  #   logging_config {
  #     log_format = "Text"
  #     log_group  = aws_cloudwatch_log_group.lambda.name
  #   }

}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/list_s3_buckets"
  retention_in_days = 14
}


data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "${path.root}/build/lambda_handler.py"
  output_path = "${path.root}/lambda_function.zip"
}
