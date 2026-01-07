This guide covers deploying your Gutter Press application to production. Whether you're using traditional servers, containers, or platform-as-a-service, we've got you covered.

## Pre-Deployment Checklist

Before deploying, ensure you have:

- [ ] Run all tests: `rails test`
- [ ] Compiled assets: `rails assets:precompile`
- [ ] Set production credentials
- [ ] Configured production database
- [ ] Set up file storage (S3, GCS, etc.)
- [ ] Reviewed security settings

---

## Environment Variables

Set these environment variables in production:

```bash
# Required
RAILS_ENV=production
SECRET_KEY_BASE=your-secret-key-base
DATABASE_URL=postgres://user:pass@host/dbname

# File Storage (if using S3)
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
AWS_BUCKET=your-bucket-name

# Optional
RAILS_LOG_LEVEL=info
RAILS_SERVE_STATIC_FILES=true
```

---

## Deploying with Kamal

Gutter Press works beautifully with [Kamal](https://kamal-deploy.org/), the deployment tool from 37signals.

### Setup

```bash
$ bundle add kamal
$ kamal init
```

### Configuration

```yaml
# config/deploy.yml
service: gutter-press

image: your-registry/gutter-press

servers:
  web:
    - 192.168.1.1
  job:
    hosts:
      - 192.168.1.1
    cmd: bin/jobs

registry:
  username: your-username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  clear:
    RAILS_ENV: production
    RAILS_LOG_LEVEL: info
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL

volumes:
  - "gutter_press_storage:/rails/storage"

asset_path: /rails/public/assets

builder:
  multiarch: false

accessories:
  db:
    image: postgres:16
    host: 192.168.1.1
    port: 5432
    env:
      clear:
        POSTGRES_DB: gutter_press_production
      secret:
        - POSTGRES_PASSWORD
    volumes:
      - gutter_press_db:/var/lib/postgresql/data
```

### Deploy

```bash
$ kamal setup    # First time only
$ kamal deploy   # Subsequent deployments
```

---

## Deploying with Docker

### Dockerfile

Gutter Press includes a production-ready Dockerfile:

```dockerfile
# Dockerfile
FROM ruby:3.4-slim

WORKDIR /rails

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment true && \
    bundle config set --local without 'development test' && \
    bundle install

# Copy application
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE=dummy rails assets:precompile

# Start server
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://postgres:password@db/gutter_press
      - RAILS_ENV=production
      - RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
    depends_on:
      - db
    volumes:
      - storage:/rails/storage

  db:
    image: postgres:16
    volumes:
      - postgres:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: gutter_press

volumes:
  storage:
  postgres:
```

---

## Platform Deployments

### Heroku

```bash
# Create app
$ heroku create my-gutter-press

# Add PostgreSQL
$ heroku addons:create heroku-postgresql:essential-0

# Add Redis (for Action Cable)
$ heroku addons:create heroku-redis:mini

# Set master key
$ heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# Deploy
$ git push heroku main

# Run migrations
$ heroku run rails db:migrate
```

### Render

Create a `render.yaml`:

```yaml
services:
  - type: web
    name: gutter-press
    runtime: ruby
    buildCommand: bundle install && rails assets:precompile
    startCommand: rails server
    envVars:
      - key: RAILS_MASTER_KEY
        sync: false
      - key: DATABASE_URL
        fromDatabase:
          name: gutter-press-db
          property: connectionString

databases:
  - name: gutter-press-db
    plan: starter
```

### Fly.io

```bash
# Initialize
$ fly launch

# Deploy
$ fly deploy

# Open
$ fly open
```

---

## File Storage in Production

### Amazon S3

```ruby
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  region: <%= ENV['AWS_REGION'] %>
  bucket: <%= ENV['AWS_BUCKET'] %>
```

```ruby
# config/environments/production.rb
config.active_storage.service = :amazon
```

### Google Cloud Storage

```ruby
# config/storage.yml
google:
  service: GCS
  credentials: <%= ENV['GOOGLE_CLOUD_KEYFILE'] %>
  project: <%= ENV['GOOGLE_CLOUD_PROJECT'] %>
  bucket: <%= ENV['GOOGLE_CLOUD_BUCKET'] %>
```

---

## SSL Configuration

### With Kamal

Kamal can configure Traefik for automatic Let's Encrypt SSL:

```yaml
# config/deploy.yml
traefik:
  options:
    publish:
      - "443:443"
    volume:
      - "/letsencrypt:/letsencrypt"
  args:
    entrypoints.websecure.address: ":443"
    certificatesresolvers.letsencrypt.acme.email: "admin@example.com"
    certificatesresolvers.letsencrypt.acme.storage: "/letsencrypt/acme.json"
    certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint: "web"
```

### With Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Performance Optimization

### Asset Delivery

Use a CDN for static assets:

```ruby
# config/environments/production.rb
config.asset_host = 'https://cdn.example.com'
```

### Caching

Enable caching for better performance:

```ruby
# config/environments/production.rb
config.cache_classes = true
config.action_controller.perform_caching = true
config.cache_store = :solid_cache_store
```

### Database Connection Pooling

```yaml
# config/database.yml
production:
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
```

---

## Monitoring

### Health Checks

Gutter Press includes a health check endpoint:

```
GET /up
```

Returns `200 OK` when the application is healthy.

### Logging

Configure structured logging for production:

```ruby
# config/environments/production.rb
config.log_level = :info
config.log_tags = [:request_id]
config.logger = ActiveSupport::Logger.new(STDOUT)
```

---

<div class="cta-box">
  <h3>Need more help?</h3>
  <p>Check out the source code or open an issue on GitHub.</p>
  <a href="https://github.com/BillyRuffian/gutter_press" class="button button-primary">View on GitHub →</a>
</div>
