data "aws_iam_policy_document" "assume_aws_batch_service" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "batch.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "aws_batch_service_role" {
  name               = "aws-batch-service-role"
  assume_role_policy = data.aws_iam_policy_document.assume_aws_batch_service.json
  depends_on = [
    data.aws_iam_policy_document.assume_aws_batch_service
  ]
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
  depends_on = [
    aws_iam_role.aws_batch_service_role
  ]
}

resource "aws_batch_compute_environment" "batch_compute_env" {
  compute_environment_name = "${var.system}-compute-env"
  compute_resources {
    max_vcpus          = 256
    security_group_ids = [aws_security_group.sg.id]
    subnets            = [aws_subnet.public_subnet.id]
    type               = "FARGATE_SPOT"
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  tags = {
    Name = "${var.system}-compute-env"
  }
  depends_on = [
    aws_security_group.sg,
    aws_subnet.public_subnet,
    aws_iam_role_policy_attachment.aws_batch_service_role
  ]
}

resource "aws_batch_job_queue" "batch_job_queue" {
  name                 = "${var.system}-job-queue"
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.batch_compute_env.arn]
  tags = {
    Name = "${var.system}-job-queue"
  }
  depends_on = [
    aws_batch_compute_environment.batch_compute_env
  ]
}

data "aws_iam_policy_document" "assume_ecs_tasks_service" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "aws_batch_job_role" {
  name               = "aws-batch-job-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs_tasks_service.json
  depends_on = [
    data.aws_iam_policy_document.assume_ecs_tasks_service
  ]
}

resource "aws_iam_role_policy_attachment" "aws_batch_job_role" {
  role       = aws_iam_role.aws_batch_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  depends_on = [
    aws_iam_role.aws_batch_service_role
  ]
}

resource "aws_iam_role" "aws_batch_execution_role" {
  name               = "aws-batch-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs_tasks_service.json
  depends_on = [
    data.aws_iam_policy_document.assume_ecs_tasks_service
  ]
}

resource "aws_iam_role_policy_attachment" "aws_batch_execution_role" {
  role       = aws_iam_role.aws_batch_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  depends_on = [
    aws_iam_role.aws_batch_service_role
  ]
}

resource "aws_batch_job_definition" "busybox_job_definition" {
  name = "${var.system}-busy-box-job-definition"
  type = "container"
  platform_capabilities = [
    "FARGATE",
  ]
  container_properties = templatefile(
    "container_properties/busybox.tftpl",
    {
      execution_role_arn = aws_iam_role.aws_batch_execution_role.arn
      job_role_arn       = aws_iam_role.aws_batch_job_role.arn
  })
  tags = {
    "Name" = "${var.system}-busy-box-job-definition"
  }
  depends_on = [
    aws_iam_role.aws_batch_execution_role,
    aws_iam_role.aws_batch_job_role
  ]
}
