# Runtime-only image: dist/ is built once in CI (astro build) and copied in.
FROM nginxinc/nginx-unprivileged:1.31-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY dist/ /usr/share/nginx/html/

# High non-root UID/GID; nginx-unprivileged runs as any UID (it only writes to /tmp).
USER 10101:10101

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO /dev/null http://127.0.0.1:8080/healthz || exit 1
