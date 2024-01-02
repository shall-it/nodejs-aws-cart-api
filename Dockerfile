# FROM node:lts-alpine AS builder
# USER node
# WORKDIR /build
# COPY package*.json ./
# RUN npm install --legacy-peer-deps && npm cache clean --force
# COPY ./ ./
# RUN npx nest build --webpack

# FROM node:lts-alpine
# EXPOSE 4000
# USER node
# WORKDIR /app
# COPY --from=builder /build/dist ./dist
# ENTRYPOINT ["node", "dist/main.js"]


FROM node:18-alpine AS builder
WORKDIR /build
COPY package*.json ./
RUN npm install --legacy-peer-deps && npm cache clean --force
COPY ./ ./
RUN npm run build

FROM node:18-alpine
EXPOSE 4000
ENV PORT=4000
WORKDIR /app
COPY --from=builder /build/package*.json ./
RUN npm ci --only=production --legacy-peer-deps && npm cache clean --force
COPY --from=builder /build/dist ./dist
CMD ["node", "dist/main.js"]