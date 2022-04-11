# Lambda
variable "handler" {
  type        = string
  description = "Name of handler"
}

variable "function_name" {
  type        = string
  description = "Name of created function and API Gateway"
}

variable "collector_layer_arn" {
  type        = string
  description = "ARN for the Lambda layer containing the OpenTelemetry collector extension"
}

variable "tracing_mode" {
  type        = string
  description = "Lambda function tracing mode"
  default     = "PassThrough"
}

variable "architecture" {
  type        = string
  description = "Lambda function architecture, valid values are arm64 or x86_64"
  default     = "x86_64"
}

variable "create_package" {
  type = bool
  default = false
}

variable "runtime" {
  type        = string
  description = "Python runtime version used for sample Lambda Function"
  default     = "python3.9"
}

variable "memory_size" {
  type        = number
  description = "Python memory size"
  default     = 384
}

variable "timeout" {
  type        = number
  description = "Python timeout"
  default     = 20
}

variable "policy_statements" {
  type = any
}

variable "environment_variables" {
  type = any
}

# Utils
variable "source_dir" {
  description = "The source file (relative path to modules/lambda)"
}

variable "zip_file" {
  description = "The output of the zip file"
}
