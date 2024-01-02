FROM node:lts-alpine AS builder
USER node
WORKDIR /build
COPY package*.json ./
RUN npm install --legacy-peer-deps && npm cache clean --force
COPY ./ ./
RUN npx nest build --webpack

FROM node:lts-alpine
EXPOSE 4000
USER node
WORKDIR /app
COPY --from=builder /build/dist ./dist
ENTRYPOINT ["node", "dist/main.js"]
