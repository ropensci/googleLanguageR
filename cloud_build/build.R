library(googleCloudRunner)

cr_deploy_packagetests(
  steps = cr_buildstep_secret("googlelanguager-auth", "/workspace/auth.json"),
  cloudbuild_file = "cloud_build/cloudbuild-tests.yml",
  timeout = 2400,
  env = c("NOT_CRAN=true","GL_AUTH=/workspace/auth.json")
)

cr_deploy_pkgdown(
  steps = cr_buildstep_secret("googlelanguager-auth", "/workspace/auth.json"),
  secret = "github-ssh",
  github_repo = "ropensci/googleLanguageR",
  cloudbuild_file = "cloud_build/cloudbuild-pkgdown.yml",
  env = "GL_AUTH=/workspace/auth.json",
  post_clone = cr_buildstep_bash(
    c("git remote set-url --push origin git@github.com:MarkEdmondson1234/googleLanguageR.git"),
    name = "gcr.io/cloud-builders/git",
    entrypoint = "bash",
    dir = "repo")
)
