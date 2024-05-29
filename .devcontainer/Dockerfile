# Use Alpine Linux as the base image
FROM alpine:latest

# Install essential build tools and curl
RUN apk update && apk add --no-cache \
    build-base \
    curl \
    git \
    zig \
    jq

WORKDIR /workspace