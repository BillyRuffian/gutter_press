Welcome to Gutter Press! This guide will walk you through cloning and setting up your own Gutter Press instance.

## Requirements

Before you begin, ensure you have:

- **Ruby 3.2+** (Ruby 3.4 recommended)
- **Git** for cloning the repository
- **Node.js 20+** (for asset compilation)
- A database (SQLite works out of the box, or PostgreSQL/MySQL for production)

## Installation

### Step 1: Clone the Repository

Clone Gutter Press from GitHub:

```bash
$ git clone https://github.com/BillyRuffian/gutter_press.git my-blog
$ cd my-blog
```

Replace `my-blog` with whatever you'd like to call your project.

### Step 2: Install Dependencies

Install Ruby gems and JavaScript packages:

```bash
$ bundle install
```

### Step 3: Set Up the Database

Create and migrate the database:

```bash
$ rails db:create
$ rails db:migrate
```

### Step 4: Start the Development Server

Use the dev script to start all services:

```bash
$ bin/dev
```

Visit `http://localhost:3000` to see Gutter Press in action!

### Step 5: Create Your First User

Sign up for an account at `http://localhost:3000` and start creating content.

---

## Configuration

Gutter Press works out of the box with sensible defaults. Key configuration files:

### Database

Configure your database in `config/database.yml`. SQLite is the default for development:

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
```

### Environment Variables

For production, set these environment variables:

```bash
RAILS_MASTER_KEY=your-master-key
DATABASE_URL=postgres://user:pass@host/dbname
```

### Customization

Since you own the code, you can modify anything:

- **Views**: `app/views/` - Customize all templates
- **Styles**: `app/assets/stylesheets/` - Modify the look and feel
- **Controllers**: `app/controllers/` - Change behavior
- **Models**: `app/models/` - Extend functionality

---

## Next Steps

Now that Gutter Press is installed, explore these guides:

<div class="columns-two">
  <div class="feature-card">
    <h3><a href="/content-editing">Content Editing</a></h3>
    <p>Learn how to create and format beautiful content with the Lexxy editor.</p>
  </div>
  <div class="feature-card">
    <h3><a href="/themes">Themes</a></h3>
    <p>Customize the look and feel of your Gutter Press installation.</p>
  </div>
</div>

---

## Troubleshooting

### Assets not compiling?

Make sure you're using `bin/dev` which runs the asset pipeline:

```bash
$ bin/dev
```

Or manually build assets:

```bash
$ rails assets:precompile
```

### Database errors?

Make sure all migrations have run:

```bash
$ rails db:migrate:status
```

Reset the database if needed:

```bash
$ rails db:reset
```

### Need help?

- Check the [GitHub Issues](https://github.com/BillyRuffian/gutter_press/issues)
- Open a new issue if you've found a bug
