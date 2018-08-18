library(httptest)
set_requester(function (request) {
  gsub_request(request, "https\\://(.+).googleapis.com/", "api/")
})
