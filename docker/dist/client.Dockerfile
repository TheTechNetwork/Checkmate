###############  builder  ###############
FROM --platform=$BUILDPLATFORM node:20-alpine AS build

# Memory tweak for large bundles
ENV NODE_OPTIONS="--max-old-space-size=4096"
# Tell Rollup to skip its optional native add-on (avoids missing arm64 binary)
ENV ROLLUP_NO_BINARY=true

WORKDIR /app

# Build-time packages
RUN apk add --no-cache \
    python3 \
    make g++ \
    gcc \
    libc-dev \
    linux-headers \
    libusb-dev \
    eudev-dev

# Install exact deps without optional native binaries
COPY ./client/package*.json ./
RUN npm ci --omit=optional          # reproducible & smaller than plain `npm install`

# Build the client
COPY ./client .
RUN npm run build

###############  runtime  ###############
FROM nginx:1.27.1-alpine

# Nginx config
COPY ./docker/dist/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# Statically built assets
COPY --from=build /app/dist /usr/share/nginx/html
COPY --from=build /app/env.sh /docker-entrypoint.d/env.sh
RUN chmod +x /docker-entrypoint.d/env.sh

CMD ["nginx", "-g", "daemon off;"]
