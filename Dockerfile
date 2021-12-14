# Dependencies
FROM node:16-bullseye-slim AS deps
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json /app/
RUN \
  npm ci --only=production

# Build
FROM node:16-bullseye-slim AS build
WORKDIR /app
COPY package.json package-lock.json tsconfig.json /app/
COPY ./src /app/src
RUN \
  npm install && \
  npm run build

# Release
FROM node:16-bullseye-slim AS release
WORKDIR /app
ENV NODE_ENV=production
COPY --from=deps /app/node_modules /app
COPY --from=build /app/dist/ /app
CMD ["node", "app.js"]
