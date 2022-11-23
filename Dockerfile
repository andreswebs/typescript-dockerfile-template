# Dependencies
FROM node:18-bullseye-slim AS deps
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json /app/
RUN npm ci

# Build
FROM node:18-bullseye-slim AS build
WORKDIR /app
COPY package.json package-lock.json tsconfig.json /app/
COPY ./src /app/src
RUN \
  npm install && \
  npm run build

# Release
FROM node:18-bullseye-slim AS release
WORKDIR /home/node/app
RUN chown -R node:node /home/node/app
ENV NODE_ENV=production
COPY --from=deps --chown=node:node /app/node_modules /home/node/app
COPY --from=build --chown=node:node /app/dist/ /home/node/app
CMD ["node", "app.js"]
