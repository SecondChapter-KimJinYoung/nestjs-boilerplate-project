# ─── 빌드 ────────────────────────────────────────────
FROM node:20-alpine AS builder

RUN corepack enable && corepack prepare yarn@stable --activate

WORKDIR /app

COPY package.json yarn.lock .yarnrc.yml* ./
COPY .yarn ./.yarn 2>/dev/null || true
RUN yarn install --immutable

COPY . .
RUN yarn build

# ─── 프로덕션 ────────────────────────────────────────
FROM node:20-alpine

RUN corepack enable && corepack prepare yarn@stable --activate

WORKDIR /app

RUN addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001

COPY package.json yarn.lock .yarnrc.yml* ./
COPY .yarn ./.yarn 2>/dev/null || true
RUN yarn plugin import workspace-tools 2>/dev/null || true && \
    (yarn workspaces focus --production 2>/dev/null || yarn install --immutable) && \
    yarn cache clean

COPY --from=builder --chown=appuser:nodejs /app/dist ./dist

USER appuser

ENV NODE_ENV=production
ENV PORT=3001

EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=3s --start-period=15s \
  CMD node -e "require('http').get('http://localhost:3001/health',(r)=>{process.exit(r.statusCode===200?0:1)})" || exit 1

CMD ["node", "dist/main.js"]
