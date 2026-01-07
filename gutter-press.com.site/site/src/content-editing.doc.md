The Lexxy editor in Gutter Press provides a powerful, intuitive content creation experience. This guide covers everything you need to know to create beautiful content.

## The Editor Interface

When you create or edit a post, you'll see the Lexxy editor with its toolbar at the top:

### Toolbar Overview

The toolbar is organized into logical groups:

| Group | Tools |
|-------|-------|
| **Text Formatting** | Bold, Italic, Underline, Strikethrough |
| **Headings** | H1, H2, H3, H4, H5, H6 |
| **Lists** | Bullet list, Numbered list, Task list |
| **Blocks** | Blockquote, Code block, Horizontal rule |
| **Media** | Image upload, Link |
| **Tables** | Insert table, Table controls |

---

## Text Formatting

### Basic Formatting

Select text and click the appropriate button, or use keyboard shortcuts:

| Format | Shortcut |
|--------|----------|
| **Bold** | `Ctrl/Cmd + B` |
| *Italic* | `Ctrl/Cmd + I` |
| <u>Underline</u> | `Ctrl/Cmd + U` |
| ~~Strikethrough~~ | `Ctrl/Cmd + Shift + X` |

### Headings

Structure your content with headings. Use the dropdown or keyboard shortcuts:

| Heading | Shortcut |
|---------|----------|
| Heading 1 | `Ctrl/Cmd + Alt + 1` |
| Heading 2 | `Ctrl/Cmd + Alt + 2` |
| Heading 3 | `Ctrl/Cmd + Alt + 3` |

---

## Lists

### Bullet Lists

Create unordered lists for items without a specific sequence:

- First item
- Second item
- Third item with nested content
  - Nested item
  - Another nested item

### Numbered Lists

Use numbered lists for sequential steps or ranked items:

1. First step
2. Second step
3. Third step

### Task Lists

Create interactive checklists:

- [ ] Incomplete task
- [x] Completed task
- [ ] Another task

---

## Images

### Uploading Images

You can add images in several ways:

1. **Click the image button** in the toolbar
2. **Drag and drop** an image directly into the editor
3. **Paste** an image from your clipboard

### Image Handling

Gutter Press automatically:

- Converts images to efficient formats
- Creates responsive variants
- Optimizes for web delivery
- Stores in your configured storage service

---

## Tables

Tables are perfect for structured data. Here's how to work with them:

### Creating a Table

1. Click the table button in the toolbar
2. Select the initial grid size
3. Click to insert

### Table Controls

Once you have a table, you can:

| Action | How |
|--------|-----|
| Add row above | Right-click → Insert row above |
| Add row below | Right-click → Insert row below |
| Add column left | Right-click → Insert column left |
| Add column right | Right-click → Insert column right |
| Delete row | Right-click → Delete row |
| Delete column | Right-click → Delete column |
| Delete table | Right-click → Delete table |

### Table Styling

Tables automatically receive styling from your theme, including:

- Alternating row colors
- Header row highlighting
- Responsive behavior on mobile

---

## Code Blocks

### Inline Code

Wrap text in backticks for `inline code`.

### Code Blocks

For multi-line code, use the code block tool:

```ruby
class Post < ApplicationRecord
  has_rich_text :content
  
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  
  before_validation :generate_slug
  
  private
  
  def generate_slug
    self.slug ||= title.parameterize
  end
end
```

### Supported Languages

Lexxy supports syntax highlighting for:

<div class="columns-three">
  <div>
    <ul>
      <li>Ruby</li>
      <li>JavaScript</li>
      <li>TypeScript</li>
      <li>Python</li>
    </ul>
  </div>
  <div>
    <ul>
      <li>HTML</li>
      <li>CSS</li>
      <li>SQL</li>
      <li>JSON</li>
    </ul>
  </div>
  <div>
    <ul>
      <li>Bash</li>
      <li>YAML</li>
      <li>Markdown</li>
      <li>And more...</li>
    </ul>
  </div>
</div>

---

## Blockquotes

Use blockquotes to highlight important quotes or callouts:

> "The best content management system is the one that gets out of your way and lets you write."
> 
> — A wise developer

---

## Links

### Adding Links

1. Select the text to link
2. Click the link button (or press `Ctrl/Cmd + K`)
3. Enter the URL
4. Click save

### Link Types

- **External links**: `https://example.com`
- **Internal links**: `/getting-started`
- **Anchor links**: `#section-name`
- **Email links**: `mailto:hello@example.com`

---

## Keyboard Shortcuts Reference

Master these shortcuts for efficient editing:

| Action | Windows/Linux | macOS |
|--------|---------------|-------|
| Bold | `Ctrl + B` | `Cmd + B` |
| Italic | `Ctrl + I` | `Cmd + I` |
| Underline | `Ctrl + U` | `Cmd + U` |
| Link | `Ctrl + K` | `Cmd + K` |
| Undo | `Ctrl + Z` | `Cmd + Z` |
| Redo | `Ctrl + Shift + Z` | `Cmd + Shift + Z` |
| Save | `Ctrl + S` | `Cmd + S` |

---

<div class="cta-box">
  <h3>Looking to customize the appearance?</h3>
  <p>Learn how to theme your Gutter Press installation.</p>
  <a href="/themes" class="button button-primary">Themes Guide →</a>
</div>
