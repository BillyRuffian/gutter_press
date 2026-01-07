Gutter Press is packed with features designed to make content creation and management a joy. Here's what you get out of the box.

## Rich Text Editing with Lexxy

At the heart of Gutter Press is **Lexxy**, a powerful WYSIWYG editor that makes content creation intuitive and beautiful.

<div class="columns-three">
  <div class="feature-card">
    <h4>📄 Rich Text</h4>
    <p>Headings, paragraphs, bold, italic, underline, strikethrough, and more.</p>
  </div>
  <div class="feature-card">
    <h4>📋 Lists</h4>
    <p>Bullet lists, numbered lists, and task lists with checkboxes.</p>
  </div>
  <div class="feature-card">
    <h4>📊 Tables</h4>
    <p>Full-featured tables with headers, alignment, and styling options.</p>
  </div>
  <div class="feature-card">
    <h4>🖼️ Images</h4>
    <p>Drag-and-drop image uploads with automatic optimization.</p>
  </div>
  <div class="feature-card">
    <h4>💻 Code Blocks</h4>
    <p>Syntax-highlighted code in dozens of languages.</p>
  </div>
  <div class="feature-card">
    <h4>💬 Blockquotes</h4>
    <p>Beautiful pullquotes and citations.</p>
  </div>
</div>

---

## Post Management

Gutter Press provides a complete content management workflow:

### Draft & Publish

- **Draft mode**: Work on content privately before it's ready
- **Scheduled publishing**: Set a future publish date
- **Instant publish**: Go live immediately

### Organization

- **Slugs**: SEO-friendly URLs generated automatically
- **Search**: Full-text search across all content
- **Pagination**: Efficient handling of large content libraries

---

## Active Storage Integration

Gutter Press leverages Rails Active Storage for robust media handling. Images are automatically processed into multiple sizes:

```ruby
post.featured_image.variant(:thumb)   # 100x100
post.featured_image.variant(:medium)  # 500x500
post.featured_image.variant(:large)   # 1200x1200
```

### Supported Formats

- **Images**: JPEG, PNG, GIF, WebP, AVIF
- **Documents**: PDF (for download links)
- **Storage**: Local disk, Amazon S3, Google Cloud, Azure

---

## Built-in Authentication

Gutter Press includes a complete authentication system out of the box:

- **User registration** - Sign up new users
- **Session management** - Secure login/logout
- **Password reset** - Email-based password recovery
- **Session security** - Automatic session expiration

Since you own the code, you can easily swap in Devise, Rodauth, or any other authentication system if you prefer.

---

## Modern Rails Architecture

Gutter Press is a complete Rails 8 application with:

- **Hotwire & Turbo** - Fast, SPA-like experience
- **Stimulus** - Modest JavaScript sprinkles
- **Importmaps** - No build step required
- **Solid Queue** - Background job processing
- **SQLite** - Zero-config database (production ready!)

```ruby
Rails.application.routes.draw do
  resources :posts
end
```

---

<div class="cta-box">
  <h3>Ready to dive deeper?</h3>
  <p>Learn how to create beautiful content with our content editing guide.</p>
  <a href="/content-editing" class="button button-primary">Content Editing Guide →</a>
</div>
