# syntax=docker/dockerfile:1

FROM node:20-bookworm AS builder
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        make \
        g++ \
        libsecret-1-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
COPY tsconfig.json tsup.config.ts ./
COPY bin ./bin
COPY src ./src
COPY README.md ./README.md

RUN npm ci
RUN npm run generate
RUN npm run build
RUN npm prune --omit=dev

FROM node:20-bookworm-slim AS runner
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libsecret-1-0 \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
ENV MS365_MCP_ORG_MODE=1
ENV MS365_MCP_CACHE_DIR=/app/cache

COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json ./package-lock.json
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "dist/index.js"]
