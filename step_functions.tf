resource "aws_sfn_state_machine" "state_machine" {
  name     = "${var.system}-state-machine"
  role_arn = aws_iam_role.aws_step_functions_role.arn
  type     = "STANDARD"

  definition = templatefile(
    "state_machines/batch_system.tftpl",
    {
      job_queue_arn      = aws_batch_job_queue.batch_job_queue.arn,
      job_definition_arn = aws_batch_job_definition.busybox_job_definition.arn
    }
  )

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.state_machine_log_group.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
  tags = {
    "Name" = "${var.system}-state-machine"
  }

  depends_on = [
    aws_iam_role.aws_step_functions_role,
    aws_batch_job_queue.batch_job_queue,
    aws_batch_job_definition.busybox_job_definition,
    aws_cloudwatch_log_group.state_machine_log_group
  ]
}

resource "aws_cloudwatch_log_group" "state_machine_log_group" {
  name              = "/aws/vendedlogs/states/${var.system}-state-machine-Logs"
  retention_in_days = 1
}



data "aws_iam_policy_document" "assume_step_functions" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "states.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "aws_step_functions_role" {
  name               = "aws-step-functions-role"
  assume_role_policy = data.aws_iam_policy_document.assume_step_functions.json
  depends_on = [
    data.aws_iam_policy_document.assume_step_functions
  ]
}

resource "aws_iam_role_policy_attachment" "aws_step_function_role_attached_batch_management" {
  role       = aws_iam_role.aws_step_functions_role.name
  policy_arn = aws_iam_policy.step_functions_batch_management_policy.arn
  depends_on = [
    aws_iam_role.aws_step_functions_role,
    aws_iam_policy.step_functions_batch_management_policy
  ]
}

resource "aws_iam_role_policy_attachment" "aws_step_function_role_attached_log_delivery" {
  role       = aws_iam_role.aws_step_functions_role.name
  policy_arn = aws_iam_policy.cloud_watch_logs_delivery_full_access_policy.arn
  depends_on = [
    aws_iam_role.aws_step_functions_role,
    aws_iam_policy.cloud_watch_logs_delivery_full_access_policy
  ]
}
