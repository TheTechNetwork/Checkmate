###############  builder  ###############
FROM --platform=$BUILDPLATFORM node:20-alpine AS build

# Allow bigger JS heaps during bundling
ENV NODE_OPTIONS="--max-old-space-size=4096"

WORKDIR /app

# Tools needed to compile native add-ons
RUN apk add --no-cache \
    python3 \
    make g++ \
    gcc \
    libc-dev \
    linux-headers \
    libusb-dev \
    eudev-dev

# ----- install deps -----
COPY ./client/package*.json ./
RUN npm ci

# ----- compile Rollup's native binding for musl + current arch -----
RUN npm rebuild @rollup/rollup --build-from-source

# ----- build the client -----
COPY ./client .
RUN npm run build

###############  runtime  ###############
FROM nginx:1.27.1-alpine

COPY ./docker/dist/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
COPY --from=build /app/env.sh /docker-entrypoint.d/env.sh
RUN chmod +x /docker-entrypoint.d/env.sh

CMD ["nginx", "-g", "daemon off;"]
