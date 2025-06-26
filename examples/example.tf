terraform {
  required_version = ">= 1.9.0"
}

module "tf-github-actions" {
  source = "github.com/bingamon-lab-tf-modules/tf-github-actions?ref=v1.0.0"
  #version = "0.1.0"

  # TFVars go here

}
