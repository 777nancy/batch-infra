data "aws_iam_policy_document" "assume_eventbridge_service" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}
resource "aws_iam_role" "aws_eventbridge_role" {
  name               = "aws-eventbridge-role"
  assume_role_policy = data.aws_iam_policy_document.assume_eventbridge_service.json
  depends_on = [
    data.aws_iam_policy_document.assume_eventbridge_service
  ]
}

resource "aws_iam_role_policy_attachment" "aws_eventbridge_role" {
  role       = aws_iam_role.aws_eventbridge_role.name
  policy_arn = aws_iam_policy.eventbrigde_invork_step_functions_policy.arn
  depends_on = [
    aws_iam_role.aws_eventbridge_role,
    aws_iam_policy.eventbrigde_invork_step_functions_policy
  ]
}


resource "aws_cloudwatch_event_rule" "daily_batch" {
  is_enabled          = false
  name                = "${var.system}-daily-invorking"
  schedule_expression = "cron(0 23 * * ? *)"
  tags = {
    Name = "${var.system}-daily-invorking"
  }
}



resource "aws_cloudwatch_event_target" "step_functions" {
  arn      = aws_sfn_state_machine.state_machine.arn
  role_arn = aws_iam_role.aws_eventbridge_role.arn
  rule     = aws_cloudwatch_event_rule.daily_batch.name
}
