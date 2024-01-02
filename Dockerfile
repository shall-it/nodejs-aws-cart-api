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