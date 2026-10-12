# Runtime-only image: dist/ is built once in CI (astro build) and copied in.
FROM nginxinc/nginx-unprivileged:1.31-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY dist/ /usr/share/nginx/html/

EXPOSE 8080
