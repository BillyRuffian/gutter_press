# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create management user
puts "Creating management user..."

admin_user = User.find_or_create_by!(email_address: "manage@gutterpress.test") do |user|
  user.password = "gutterpress"
  user.password_confirmation = "gutterpress"
end

puts "✅ Management user created with email: #{admin_user.email_address}"

# Create sample content for demonstration
puts "Creating sample content..."

# Sample post
sample_post = Post.find_or_create_by!(slug: "welcome-to-gutterpress") do |post|
  post.publish = true
  post.title = "Welcome to GutterPress"
  post.content = <<~CONTENT
    <p>Welcome to <strong>GutterPress</strong>, a modern blogging platform built with Rails 8.1!</p>

    <h2>Features</h2>
    <ul>
      <li>Slug-based URLs for SEO-friendly links</li>
      <li>Rich text editing with Lexxy</li>
      <li>Internal linking with # prompts</li>
      <li>Clean management interface</li>
    </ul>

    <p>Get started by visiting the <a href="/manage">management interface</a> and creating your first post!</p>
  CONTENT
  post.excerpt = "An introduction to GutterPress and its features"
  post.user = admin_user
  post.published_at = Time.current
end

# Sample page
sample_page = Page.find_or_create_by!(slug: "about") do |page|
  page.publish = true
  page.title = "About"
  page.content = <<~CONTENT
    <p>This is a sample <strong>About</strong> page created during the seeding process.</p>

    <p>Pages are perfect for static content like:</p>
    <ul>
      <li>About information</li>
      <li>Contact details</li>
      <li>Privacy policies</li>
      <li>Terms of service</li>
    </ul>

    <p>You can edit this page or create new ones from the <a href="/manage/pages">pages management</a> section.</p>
  CONTENT
  page.excerpt = "Learn more about this GutterPress site"
  page.user = admin_user
  page.published_at = Time.current
end

puts "✅ Sample post created: #{sample_post.title} (/posts/#{sample_post.slug})"
puts "✅ Sample page created: #{sample_page.title} (/pages/#{sample_page.slug})"

# Create default site settings
puts "Creating default site settings..."

# Use the defaults from the model to keep it DRY
SiteSetting::DEFAULTS.each do |key, value|
  setting = SiteSetting.find_or_initialize_by(key: key)
  if setting.new_record?
    setting.value = value
    setting.save!
    puts "✅ Site setting created: #{key} = #{value}"
  else
    puts "⚡ Site setting exists: #{key} = #{setting.value}"
  end
end

puts "\n🎉 Seeding complete!"
puts "\nYou can now:"
puts "  • Visit the site at: http://localhost:3000"
puts "  • Login to manage content at: http://localhost:3000/sessions/new"
puts "  • Email: manage@gutterpress.test"
puts "  • Password: gutterpress"
