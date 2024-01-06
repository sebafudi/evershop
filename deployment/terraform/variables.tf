locals {
  raw_data   = jsondecode(file("../../deployment.env/credentials.json"))
  project_id = local.raw_data.project_id
}
