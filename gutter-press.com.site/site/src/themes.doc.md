Gutter Press gives you complete control over the look and feel of your site through CSS. Since you own the code, you can edit any stylesheet directly.

## Stylesheet Structure

The main stylesheets are located in `app/assets/stylesheets/`:

```
app/assets/stylesheets/
├── application.bootstrap.scss   # Main stylesheet with Bootstrap
├── lexxy-variables.css          # Lexxy editor CSS variables
├── lexxy-editor.css             # Editor styling
└── lexxy-content.css            # Content display styling
```

---

## Customizing the Look

### Editing the Main Stylesheet

Open `app/assets/stylesheets/application.bootstrap.scss` to customize the overall appearance:

```scss
/* app/assets/stylesheets/application.bootstrap.scss */

/* Override Bootstrap variables */
$primary: #cc0000;
$font-family-base: 'Source Serif Pro', Georgia, serif;

/* Import Bootstrap */
@import 'bootstrap/scss/bootstrap';

/* Add your custom styles */
.post-title {
  font-family: 'Playfair Display', Georgia, serif;
  font-size: 2.5rem;
  font-weight: 700;
}

.post-content {
  font-size: 1.125rem;
  line-height: 1.8;
  max-width: 720px;
}
```

---

## Lexxy Editor Styling

The Lexxy rich text editor uses CSS variables for easy theming.

### Editor Variables

Edit `app/assets/stylesheets/lexxy-variables.css` to customize the editor:

```css
/* app/assets/stylesheets/lexxy-variables.css */

:root {
  /* Editor colors */
  --lexxy-color-canvas: #ffffff;
  --lexxy-color-ink: #1a1a1a;
  --lexxy-color-ink-light: #6a6a6a;
  
  /* Toolbar */
  --lexxy-toolbar-bg: #f8f8f8;
  --lexxy-toolbar-border: #e0e0e0;
  
  /* Accent colors */
  --lexxy-color-accent: #cc0000;
  
  /* Typography */
  --lexxy-font-body: 'Source Serif Pro', Georgia, serif;
  --lexxy-font-mono: 'JetBrains Mono', monospace;
}
```

### Content Display

Edit `app/assets/stylesheets/lexxy-content.css` to style how content appears to readers:

```css
/* app/assets/stylesheets/lexxy-content.css */

.lexxy-content {
  font-family: var(--lexxy-font-body);
  font-size: 1.125rem;
  line-height: 1.8;
}

.lexxy-content h1,
.lexxy-content h2,
.lexxy-content h3 {
  font-family: 'Playfair Display', serif;
  font-weight: 700;
  margin-top: 2rem;
}

.lexxy-content blockquote {
  border-left: 4px solid var(--lexxy-color-accent);
  padding-left: 1.5rem;
  font-style: italic;
}
```

---

## Dark Mode Support

Add dark mode support in `lexxy-variables.css`:

```css
/* Light mode (default) */
:root {
  --lexxy-color-canvas: #ffffff;
  --lexxy-color-ink: #1a1a1a;
}

/* Dark mode */
@media (prefers-color-scheme: dark) {
  :root {
    --lexxy-color-canvas: #1a1a1a;
    --lexxy-color-ink: #e8e4dc;
    --lexxy-toolbar-bg: #2d2d2d;
    --lexxy-toolbar-border: #404040;
  }
}
```

---

## Typography

### Recommended Typographic Scale

| Element | Size | Line Height |
|---------|------|-------------|
| H1 | 2.5rem | 1.2 |
| H2 | 2rem | 1.25 |
| H3 | 1.75rem | 1.3 |
| H4 | 1.5rem | 1.4 |
| Body | 1.125rem | 1.7 |
| Small | 0.875rem | 1.5 |

### Adding Custom Fonts

Add fonts to your layout in `app/views/layouts/application.html.erb`:

```erb
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Source+Serif+Pro:wght@400;600&display=swap" rel="stylesheet">
```

Then reference them in your CSS:

```css
.post-content {
  font-family: 'Source Serif Pro', Georgia, serif;
}

.post-title {
  font-family: 'Playfair Display', serif;
}
```

---

## Code Block Styling

Customize syntax highlighting for code blocks:

```css
/* In lexxy-content.css or application.bootstrap.scss */

.lexxy-content pre {
  background: #1e1e1e;
  color: #d4d4d4;
  padding: 1rem;
  border-radius: 4px;
  overflow-x: auto;
  border-left: 4px solid #cc0000;
}

.lexxy-content code {
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  font-size: 0.9em;
}

/* Inline code */
.lexxy-content p code {
  background: #f4f4f4;
  padding: 0.2em 0.4em;
  border-radius: 3px;
}
```

---

<div class="cta-box">
  <h3>Ready to go live?</h3>
  <p>Learn how to deploy your Gutter Press site to production.</p>
  <a href="/deployment" class="button button-primary">Deployment Guide →</a>
</div>
