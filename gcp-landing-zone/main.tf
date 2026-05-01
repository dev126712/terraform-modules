module "org_structure" {
  source          = "./modules"
  org_id          = var.org_id
  billing_account = var.billing_account
  prefix          = var.prefix

  seed_project_id = var.seed_project_id
  region          = var.region
  zone            = var.zone
}
