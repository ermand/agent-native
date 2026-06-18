# syntax=docker/dockerfile:1.7
FROM node:22-bookworm-slim AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
WORKDIR /app
RUN corepack enable
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

FROM base AS build
RUN apt-get update \
  && apt-get install -y --no-install-recommends git python3 make g++ \
  && rm -rf /var/lib/apt/lists/*
ARG APP_NAME=starter
COPY . .
RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store pnpm install --frozen-lockfile --filter "$APP_NAME..."
RUN pnpm --filter "$APP_NAME..." build

FROM base AS runner
ARG APP_NAME=starter
ENV APP_NAME="$APP_NAME"
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000
COPY --from=build /app /app
WORKDIR /app/templates/${APP_NAME}
EXPOSE 3000
CMD ["pnpm", "start"]
