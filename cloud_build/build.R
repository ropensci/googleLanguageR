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
  github_repo = "MarkEdmondson1234/googleLanguageR",
  cloudbuild_file = "cloud_build/cloudbuild-pkgdown.yml",
  env = "GL_AUTH=/workspace/auth.json"
)

# add step after cloning:
# - name: gcr.io/cloud-builders/git
# id: set git push
# args:
#   - remote
# - set-url
# - --push
# - --origin git@github.com:MarkEdmondson1234/googleLanguageR
# volumes:
#   - name: ssh
# path: /root/.ssh
