# Prevent system tests from being run accidentally
# This completely overrides Rails' default test:system task

# Clear the existing task if it exists
Rake::Task['test:system'].clear if Rake::Task.task_defined?('test:system')

namespace :test do
  desc 'Prevent system tests - they have been intentionally removed'
  task :system do
    puts ''
    puts '❌ System tests have been intentionally removed from this project.'
    puts ''
    puts 'Reasons:'
    puts '  • Caused issues with the Lexxy rich text editor'
    puts '  • Parallel test execution problems'
    puts '  • Slower CI/CD pipeline'
    puts ''
    puts 'Use these alternatives instead:'
    puts '  bin/rails test                    # Run all unit and integration tests'
    puts '  bin/rails test test/models/       # Run model tests'
    puts '  bin/rails test test/controllers/  # Run controller tests'
    puts '  bin/rails test test/integration/  # Run integration tests'
    puts ''
    puts 'If you need to add system tests back, please discuss with the team first.'
    puts ''
    exit 1
  end
end

# Also create a top-level task that Rails might call
task 'test:system' do
  Rake::Task['test:system'].invoke
end
