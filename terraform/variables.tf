variable "active_environment" {
  description = "Which environment receives traffic (blue or green)"
  type        = string
  default     = "blue"
}
variable "image_tag" {
  description = "Docker image tag from Jenkins build"
  type        = string
}
