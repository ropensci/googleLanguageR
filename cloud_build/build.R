library(googleCloudRunner)

cr_deploy_packagetests(
  steps = cr_buildstep_secret("googlelanguager-auth", "/workspace/auth.json"),
  timeout = 2400,
  env = c("NOT_CRAN=true","GL_AUTH=/workspace/auth.json")
)
