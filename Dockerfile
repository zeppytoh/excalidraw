FROM --platform=${BUILDPLATFORM} node:18 AS build

WORKDIR /opt/node_app

COPY . .

# 1. Accept the variables from Railway during the build process
ARG VITE_APP_WS_SERVER_URL
ARG VITE_APP_WS_SERVER_PATH

# 2. Set the variables as environment variables inside the build container
ENV VITE_APP_WS_SERVER_URL=$VITE_APP_WS_SERVER_URL
ENV VITE_APP_WS_SERVER_PATH=$VITE_APP_WS_SERVER_PATH
# --- END REQUIRED ADDITIONS ---

# do not ignore optional dependencies:
# Error: Cannot find module @rollup/rollup-linux-x64-gnu
# Use a unique, descriptive ID for the cache
# RUN --mount=type=cache,id=excalidraw-yarn-cache,target=/root/.cache/yarn\ 
#     npm_config_target_arch=${TARGETARCH} yarn install --frozen-lockfile --network-timeout 600000

# Note the required 's/' prefix and a unique ID for the client's yarn cache
RUN --mount=type=cache,id=s/63b12753-af1d-4ca3-ba04-9f3d7b3029aa-client-yarn-cache,target=/usr/local/share/.cache/yarn npm_config_target_arch=${TARGETARCH} yarn install --frozen-lockfile

ARG NODE_ENV=production

RUN npm_config_target_arch=${TARGETARCH} yarn build:app:docker

FROM --platform=${TARGETPLATFORM} nginx:1.27-alpine

COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
