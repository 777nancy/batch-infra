data "aws_caller_identity" "self" {}

data "aws_iam_policy_document" "step_functions_batch_management" {
  statement {
    effect = "Allow"
    actions = [
      "batch:SubmitJob",
      "batch:DescribeJobs",
      "batch:TerminateJob"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = [
      "arn:aws:events:${var.region}:${data.aws_caller_identity.self.account_id}:rule/StepFunctionsGetEventsForBatchJobsRule"
    ]
  }
}

resource "aws_iam_policy" "step_functions_batch_management_policy" {
  name   = "step-functions-batch-management-policy"
  policy = data.aws_iam_policy_document.step_functions_batch_management.json
  depends_on = [
    data.aws_iam_policy_document.step_functions_batch_management
  ]
}

data "aws_iam_policy_document" "cloud_watch_logs_delivery_full_access" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "cloud_watch_logs_delivery_full_access_policy" {
  name   = "cloud-watch-logs-delivery-full-access-policy"
  policy = data.aws_iam_policy_document.cloud_watch_logs_delivery_full_access.json
  depends_on = [
    data.aws_iam_policy_document.cloud_watch_logs_delivery_full_access
  ]
}

data "aws_iam_policy_document" "eventbrigde_invork_step_functions" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.state_machine.arn
    ]
  }
}

resource "aws_iam_policy" "eventbrigde_invork_step_functions_policy" {
  name   = "eventbrigde_invork_step_functions"
  policy = data.aws_iam_policy_document.eventbrigde_invork_step_functions.json
  depends_on = [
    data.aws_iam_policy_document.eventbrigde_invork_step_functions
  ]
}
