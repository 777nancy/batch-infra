variable "region" {
  description = "region"
  type        = string
  default     = "us-west-2"
}

variable "system" {
  description = "system name"
  type        = string
  default     = "batch-system"
}

variable "cidr" {
  description = "cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet" {
  description = "pulic subnet"
  type        = map(string)
  default = {
    "cidr_block"        = "10.0.0.0/24"
    "availability_zone" = "us-west-2a"
  }
}

variable "batch_schedule_expression" {
  description = "cron"
  type        = string
  default     = "cron(0 23 * * ? *)"
}
