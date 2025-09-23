# GutterPress

A modern, slug-based blogging platform built with Rails 8.1 featuring rich text editing, internal linking, and a clean management interface.

## Features

### 🔗 **Slug-Based URLs**
- Clean, SEO-friendly URLs using post/page titles instead of numeric IDs
- Automatic slug generation from titles with duplicate handling
- Unique slug validation with automatic counter increments
- Database-indexed slugs for optimal performance

### 📝 **Rich Text Editing with Lexxy**
- Modern rich text editor powered by Lexical framework
- Syntax highlighting for code blocks
- Markdown support for quick formatting
- **# Prompt Internal Linking**: Type `#` to search and link to other posts/pages
- Server-side filtering for fast link discovery

### 🎨 **Modern UI**
- Bootstrap 5 with custom styling
- Bootstrap Icons integration
- Responsive design for all screen sizes
- Clean management interface with sidebar layouts
- Professional form designs with contextual help

### 🏗️ **Flexible Content Architecture**
- Single Table Inheritance (STI) with `Postable` base class
- Unified handling of Posts and Pages
- Rich metadata support (descriptions, publishing dates, etc.)
- Flexible publishing workflow

### 🔐 **Security & Authentication**
- User authentication system
- Protected management interface
- Brakeman security scanning integration
- CSRF protection and secure headers

### 🧪 **Comprehensive Testing**
- 237 tests with 673 assertions
- Unit and integration tests
- 100% passing test suite
- Automated CI/CD ready

## Quick Start

### Prerequisites

- Ruby 3.3.5+
- Node.js 18+ and Yarn
- SQLite3 (development) or PostgreSQL (production)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/BillyRuffian/gutter_press.git
   cd gutter_press
   ```

2. **Install dependencies**
   ```bash
   # Ruby dependencies
   bundle install
   
   # Node.js dependencies
   yarn install
   ```

3. **Setup database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

4. **Start the development server**
   ```bash
   bin/dev
   ```

5. **Visit the application**
   - Main site: http://localhost:3000
   - Management interface: http://localhost:3000/manage

## Usage

### Creating Content

#### Posts
1. Navigate to `/manage/posts`
2. Click "New Post"
3. Fill in title and content using the rich text editor
4. Use `#` in the editor to link to other posts/pages
5. Configure slug in the sidebar (auto-generated if empty)
6. Set publish date and status
7. Save to publish

#### Pages
Similar to posts but accessible at `/pages/slug-name` for static content.

### Using Internal Linking

The `#` prompt feature allows you to easily link between content:

1. Type `#` in the rich text editor
2. Start typing the title of a post or page
3. Select from the filtered results
4. A properly formatted link is inserted automatically

### URL Structure

- **Posts**: `/posts/my-great-post-title`
- **Pages**: `/pages/about-us`
- **Management**: `/manage/posts` or `/manage/pages`

## Development

### Running Tests

```bash
# All tests
bin/rails test

# Specific test file
bin/rails test test/models/postable_test.rb
```

### Code Quality

```bash
# Security scan
bin/brakeman

# Linting
bin/rubocop

# Bundle audit
bin/bundler-audit
```

### Database Operations

```bash
# Create and run migrations
bin/rails generate migration AddFeatureToPostables feature:string
bin/rails db:migrate

# Rollback
bin/rails db:rollback

# Reset database
bin/rails db:drop db:create db:migrate db:seed
```

## Architecture

### Models

#### `Postable` (STI Base Class)
- **Location**: `app/models/postable.rb`
- **Purpose**: Base class for all content types
- **Key Methods**:
  - `generate_slug`: Automatic slug generation with duplicate handling
  - `to_param`: Returns slug for URL generation
  - `published?`: Check if content is published

#### `Post` & `Page`
- **Inheritance**: Both inherit from `Postable`
- **Differences**: Different routing and display contexts
- **Shared Features**: All slug functionality, rich text, metadata

### Controllers

#### Management Controllers
- **Location**: `app/controllers/manage/`
- **Purpose**: Admin interface for content management
- **Authentication**: Required for all actions
- **Features**: Full CRUD operations with slug support

#### `LinksController`
- **Location**: `app/controllers/manage/links_controller.rb`
- **Purpose**: Handles `#` prompt searches for internal linking
- **Response**: JSON data for Lexxy integration

### Views

#### Layout Structure
- **Framework**: Bootstrap 5 with custom SCSS
- **Templates**: HAML for clean, readable markup
- **Components**: Reusable form partials and UI elements

#### Rich Text Integration
- **Editor**: Lexxy with custom prompt configuration
- **Styling**: Custom CSS for proper spacing and icons
- **Features**: Syntax highlighting, markdown support, internal linking

### Database Schema

```sql
-- Postables table (STI)
CREATE TABLE postables (
  id INTEGER PRIMARY KEY,
  type VARCHAR NOT NULL,          -- 'Post' or 'Page'
  title VARCHAR NOT NULL,
  content TEXT,
  description TEXT,
  slug VARCHAR UNIQUE NOT NULL,   -- Indexed for performance
  user_id INTEGER NOT NULL,
  publish BOOLEAN DEFAULT FALSE,
  published_at DATETIME,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);

CREATE UNIQUE INDEX index_postables_on_slug ON postables (slug);
```

## Configuration

### Environment Variables

```bash
# Development
HOST=localhost
PORT=3000
RAILS_ENV=development

# Production
HOST=yourdomain.com
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key
DATABASE_URL=postgresql://...
```

### Host Configuration

#### Development
Edit `config/environments/development.rb`:
```ruby
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

#### Production
Edit `config/environments/production.rb`:
```ruby
config.action_mailer.default_url_options = { host: 'yourdomain.com' }
config.hosts = [
  "yourdomain.com",
  /.*\.yourdomain\.com/
]
```

## Deployment

### Docker

```dockerfile
# Dockerfile included in repository
FROM ruby:3.3.5
# ... (see Dockerfile for complete configuration)
```

Build and run:
```bash
docker build -t gutterpress .
docker run -p 3000:3000 gutterpress
```

### Kamal

Configuration in `config/deploy.yml`:
```yaml
service: gutterpress
image: gutterpress
servers:
  - your-server.com
# ... (see deploy.yml for complete configuration)
```

Deploy:
```bash
kamal setup
kamal deploy
```

### Traditional Deployment

1. **Server Setup**
   - Install Ruby, Node.js, and database
   - Configure web server (Nginx + Passenger/Puma)
   - Set up SSL certificates

2. **Application Deployment**
   ```bash
   # On server
   git pull origin main
   bundle install --without development test
   yarn install --production
   bin/rails assets:precompile
   bin/rails db:migrate
   sudo systemctl restart your-app
   ```

## API Reference

### Internal Linking API

**Endpoint**: `GET /manage/links`

**Parameters**:
- `query` (string): Search term for filtering posts/pages

**Response**:
```json
{
  "results": [
    {
      "title": "My Great Post",
      "slug": "my-great-post",
      "type": "Post",
      "url": "/posts/my-great-post"
    }
  ]
}
```

**Usage**: Automatically called by Lexxy editor when using `#` prompt.

## Testing

### Test Structure

```
test/
├── controllers/          # Controller unit tests
│   ├── manage/          # Management interface tests
│   └── ...
├── models/              # Model unit tests
├── integration/         # Integration tests

├── fixtures/           # Test data
└── test_helper.rb      # Test configuration
```

### Key Test Files

- **`test/models/postable_test.rb`**: Slug generation and validation
- **`test/controllers/manage/links_controller_test.rb`**: Internal linking API


### Running Specific Tests

```bash
# Model tests
bin/rails test test/models/

# Controller tests  
bin/rails test test/controllers/



# Single test
bin/rails test test/models/postable_test.rb:25
```

## Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Write tests** for your changes
4. **Ensure tests pass**: `bin/rails test`
5. **Check code quality**: `bin/rubocop`
6. **Commit changes**: `git commit -m 'Add amazing feature'`
7. **Push to branch**: `git push origin feature/amazing-feature`
8. **Open a Pull Request**

### Code Style

- Follow Ruby community conventions
- Use RuboCop for linting
- Write descriptive commit messages
- Include tests for new features
- Update documentation as needed

## Troubleshooting

### Common Issues

#### **Slug Generation Not Working**
- Check that `title` is present before save
- Verify database has unique index on `slug` column
- Review `generate_slug` method in `Postable` model

#### **Rich Text Editor Not Loading**
- Ensure Yarn dependencies are installed: `yarn install`
- Check browser console for JavaScript errors
- Verify Lexxy CSS is properly compiled: `yarn build:css`

#### **Internal Linking `#` Prompt Not Working**
- Confirm `LinksController` is responding: check `/manage/links?query=test`
- Verify route exists: `bin/rails routes | grep links`
- Check browser network tab for failed requests

#### **Tests Failing**
- Reset test database: `RAILS_ENV=test bin/rails db:reset`
- Check for pending migrations: `bin/rails db:migrate:status`
- Review specific test failure output for details

### Performance

#### **Slow Page Loads**
- Enable caching in development: `bin/rails dev:cache`
- Check database queries in logs
- Consider adding database indexes for frequent queries

#### **Large CSS Build Times**
- Sass deprecation warnings are cosmetic (Bootstrap compatibility)
- Consider upgrading to Dart Sass when Bootstrap supports it

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Rails Team** for the excellent Rails 8.1 framework
- **Lexxy** for the modern rich text editing experience
- **Bootstrap Team** for the UI framework
- **Community Contributors** for various gems and tools used

## Changelog

### v1.0.0 (Current)
- ✅ Complete slug-based URL system
- ✅ Lexxy rich text editor integration
- ✅ Internal linking with `#` prompts
- ✅ Bootstrap 5 UI with custom styling
- ✅ Comprehensive test suite (76 tests)
- ✅ Security hardening with Brakeman
- ✅ HAML templating throughout
- ✅ Single Table Inheritance architecture

---

**Built with ❤️ using Rails 8.1 and modern web technologies.**

For questions, issues, or contributions, please visit our [GitHub repository](https://github.com/BillyRuffian/gutter_press).
