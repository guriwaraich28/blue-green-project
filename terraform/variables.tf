variable "active_environment" {
  description = "Which environment receives traffic (blue or green)"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag from Jenkins build"
  type        = string
}
