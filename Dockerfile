FROM gcr.io/mark-edmondson-gde/googleauthr

RUN ["install2.r", "googleLanguageR"]

RUN ["installGithub.r", "MarkEdmondson1234/googleCloudRunner"]
