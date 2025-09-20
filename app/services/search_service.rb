class SearchService
  attr_reader :query, :results

  def initialize(query)
    @query = query&.strip
    @results = []
  end

  def perform
    return self if @query.blank? || @query.length < 2

    @results = search_posts + search_pages
    @results.sort_by { |result| -result[:relevance_score] }

    self
  end

  private

  def search_posts
    search_postables(Post.published, 'post')
  end

  def search_pages
    search_postables(Page.published, 'page')
  end

  def search_postables(scope, type)
    results = []

    # Search in title, excerpt, and content
    scope.includes(:rich_text_content).find_each do |item|
      score = 0
      title_match = nil
      excerpt_match = nil
      content_match = nil

      # Title search (highest priority)
      if item.title&.downcase&.include?(@query.downcase)
        score += 10
        title_match = highlight_text(item.title, @query)
      end

      # Excerpt search
      if item.excerpt.present? && item.excerpt.downcase.include?(@query.downcase)
        score += 5
        excerpt_match = highlight_text(item.excerpt, @query)
      end

      # Content search
      content_text = item.content.to_plain_text
      if content_text.downcase.include?(@query.downcase)
        score += 1
        content_match = extract_and_highlight_snippet(content_text, @query)
      end

      # Only include if there's a match
      if score > 0
        results << {
          type: type,
          id: item.id,
          title: title_match || item.title,
          excerpt: excerpt_match || item.display_excerpt,
          content_snippet: content_match,
          url: type == 'post' ? "/posts/#{item.slug}" : "/pages/#{item.slug}",
          published_at: item.published_at,
          relevance_score: score
        }
      end
    end

    results
  end

  def highlight_text(text, query)
    return text if text.blank? || query.blank?

    # Use case-insensitive regex to find and highlight matches
    text.gsub(/#{Regexp.escape(query)}/i) { |match| "<mark>#{match}</mark>" }
  end

  def extract_and_highlight_snippet(text, query, snippet_length = 200)
    return nil if text.blank? || query.blank?

    # Find the position of the first occurrence of the query
    query_position = text.downcase.index(query.downcase)
    return nil unless query_position

    # Calculate snippet boundaries - center the query in the snippet
    half_length = snippet_length / 2
    start_pos = [ query_position - half_length, 0 ].max
    end_pos = [ start_pos + snippet_length, text.length ].min

    # If we're near the end, adjust start_pos to get full snippet
    if end_pos == text.length && (end_pos - start_pos) < snippet_length
      start_pos = [ text.length - snippet_length, 0 ].max
    end

    # Extract snippet
    snippet = text[start_pos...end_pos]

    # Add ellipsis if we're not at the start/end
    snippet = "...#{snippet}" if start_pos > 0
    snippet = "#{snippet}..." if end_pos < text.length

    # Highlight the query in the snippet
    highlight_text(snippet, query)
  end
end
