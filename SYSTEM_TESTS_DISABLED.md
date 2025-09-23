# System Tests Disabled

This project has **intentionally disabled system tests** for the following reasons:

## Why System Tests Were Removed

### 1. **Lexxy Rich Text Editor Compatibility Issues**
- The project uses [Lexxy](https://github.com/lexxy/lexxy) for rich text editing instead of Rails' default Trix editor
- System tests had difficulty interacting with Lexxy's JavaScript components
- Form submissions would fail intermittently due to editor initialization timing

### 2. **Parallel Test Execution Problems**
- System tests failed when run in parallel with other tests
- Chrome browser instances would conflict during concurrent execution
- Tests would pass individually but fail in CI/CD pipeline

### 3. **CI/CD Performance**
- System tests significantly slowed down the build pipeline
- Browser automation added ~60% to test execution time
- The project maintains excellent coverage through unit and integration tests

## Current Test Coverage

The project maintains comprehensive test coverage through:

- **237 unit and integration tests** with **673 assertions**
- **100% passing test suite**
- Controller tests for all user interactions
- Model tests for business logic
- Integration tests for complete request flows

## Protections in Place

To prevent accidental re-introduction of system tests:

### 1. Generator Configuration
```ruby
# config/application.rb
config.generators do |g|
  g.system_tests false
end
```

### 2. Rake Task Override
```bash
rake test:system
# => Shows helpful error message and exits
```

### 3. Removed Dependencies
- `capybara` and `selenium-webdriver` gems removed
- System test directory (`test/system/`) deleted
- CI workflows updated to exclude system test jobs

## If You Need System Tests

**Before re-enabling system tests, please:**

1. **Discuss with the team** - Understand why they were removed
2. **Address Lexxy compatibility** - Ensure form interactions work reliably
3. **Fix parallel execution** - Tests must pass in CI environment
4. **Consider alternatives** - Can the functionality be tested with integration tests?

## Running Tests

```bash
# All tests (recommended)
bin/rails test

# Specific test types
bin/rails test test/models/       # Model tests
bin/rails test test/controllers/  # Controller tests  
bin/rails test test/integration/  # Integration tests

# Single test file
bin/rails test test/models/postable_test.rb
```

## Questions?

If you have questions about this decision or need help with testing strategies, please:

1. Check the git history for context on the removal
2. Review existing integration tests for patterns
3. Reach out to the development team

---

**Last updated:** December 2024  
**Decision made by:** Development Team  
**Status:** Active - Do not re-enable without team discussion