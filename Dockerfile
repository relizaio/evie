FROM node:13.10.1-buster as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install --global gulp-cli
RUN npm install
COPY ./ .
RUN gulp build

FROM nginx:1.17.8 as artifact-stage
ARG CI_ENV=noci
ARG GIT_COMMIT=git_commit_undefined
ARG GIT_BRANCH=git_branch_undefined
ARG VERSION=not_versioned
COPY --from=build-stage /app/docs /usr/share/nginx/html
RUN echo "version=$VERSION" > /usr/share/nginx/html/version.html && echo "commit=$GIT_COMMIT" >> /usr/share/nginx/html/version.html && echo "branch=$GIT_BRANCH" >> /usr/share/nginx/html/version.html
RUN chmod 0700 /usr/share/nginx/html && chmod 0644 -R /usr/share/nginx/html/*
RUN find /usr/share/nginx/html -type d -exec chmod 0700 {} \;
COPY nginx/default.conf /etc/nginx/conf.d/
COPY nginx/nginx.conf /etc/nginx/
LABEL git_commit $GIT_COMMIT
LABEL git_branch $GIT_BRANCH
LABEL ci_environment $CI_ENV
LABEL version $VERSION