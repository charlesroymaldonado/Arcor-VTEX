variable "project_id" {
    type = string
    default = "mvp-arcor-dev"
}

variable "region" {
  default = "us-central1"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "repo_sources" {
    type = string
    description = "Repositorio de codigo fuentes"
    default = "bkt_arcor_mvp_repo"
}