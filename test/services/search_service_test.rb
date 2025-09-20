require 'test_helper'

class SearchServiceTest < ActiveSupport::TestCase
  test 'should find published posts and pages by title' do
    # Using postables fixture
    service = SearchService.new('Published Test').perform

    # Results should contain hash objects, not the model objects directly
    results = service.results
    assert results.any? { |r| r[:title].include?('Published Test') }
  end

  test 'should not return draft content' do
    service = SearchService.new('Draft Test').perform

    # Should not find draft content in results
    results = service.results
    assert_equal 0, results.length
  end

  test 'should return empty array for empty query' do
    service = SearchService.new('').perform
    assert_empty service.results
  end

  test 'should return empty array for nil query' do
    service = SearchService.new(nil).perform
    assert_empty service.results
  end

  test 'should return empty array for no matches' do
    service = SearchService.new('nonexistentquerythatmatchesnothing').perform
    assert_empty service.results
  end

  test 'should highlight search terms in title' do
    service = SearchService.new('test')
    highlighted = service.send(:highlight_text, 'This is a test title', 'test')
    assert_includes highlighted, '<mark>test</mark>'
  end

  test 'should highlight multiple occurrences' do
    service = SearchService.new('test')
    highlighted = service.send(:highlight_text, 'test this test string', 'test')
    assert_equal 2, highlighted.scan('<mark>test</mark>').length
  end

  test 'should be case insensitive for highlighting' do
    service = SearchService.new('test')
    highlighted = service.send(:highlight_text, 'Test this TEST string', 'test')
    assert_includes highlighted, '<mark>Test</mark>'
    assert_includes highlighted, '<mark>TEST</mark>'
  end

  test 'should extract and highlight snippet from text' do
    service = SearchService.new('search term')
    text = 'This is a long piece of text that contains the search term somewhere in the middle of it all.'
    snippet = service.send(:extract_and_highlight_snippet, text, 'search term', 50)

    # The extracted snippet should contain the search term highlighted
    assert_includes snippet, '<mark>search term</mark>'
  end

  test 'should return full text if shorter than max length' do
    service = SearchService.new('search')
    text = 'Short text with search term'
    snippet = service.send(:extract_and_highlight_snippet, text, 'search', 50)

    assert_equal text.gsub('search', '<mark>search</mark>'), snippet
  end

  test 'should handle snippet extraction with no matches' do
    service = SearchService.new('xyz')
    text = 'This text has no matching content'
    snippet = service.send(:extract_and_highlight_snippet, text, 'xyz', 50)

    assert_nil snippet
  end

  test 'should search across content using Action Text' do
    # Test basic functionality with existing fixture data
    service = SearchService.new('First').perform

    results = service.results
    assert results.any? { |r| r[:title].include?('First') }
  end
end
