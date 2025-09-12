require 'test_helper'

class SitemapControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published_post = posts(:one)
    @unpublished_post = posts(:two)
    
    # Ensure one post is published and one is not
    @published_post.update!(published_at: 1.hour.ago)
    @unpublished_post.update!(published_at: 1.hour.from_now)
  end

  test 'should get sitemap xml' do
    get sitemap_path(format: :xml)
    assert_response :success
    assert_equal 'application/xml; charset=utf-8', @response.content_type
  end

  test 'sitemap should include homepage' do
    get sitemap_path(format: :xml)
    assert_response :success
    
    assert_match %r{<loc>#{Regexp.escape(root_url)}</loc>}, @response.body
    assert_match %r{<priority>1\.0</priority>}, @response.body
  end

  test 'sitemap should include published posts only' do
    get sitemap_path(format: :xml)
    assert_response :success
    
    # Should include published post
    assert_match %r{<loc>#{Regexp.escape(post_url(@published_post))}</loc>}, @response.body
    
    # Should not include unpublished post
    assert_no_match %r{<loc>#{Regexp.escape(post_url(@unpublished_post))}</loc>}, @response.body
  end

  test 'sitemap should have valid XML structure' do
    get sitemap_path(format: :xml)
    assert_response :success
    
    # Check XML declaration and urlset
    assert_match %r{<\?xml version="1\.0" encoding="UTF-8"\?>}, @response.body
    assert_match %r{<urlset xmlns="http://www\.sitemaps\.org/schemas/sitemap/0\.9">}, @response.body
    assert_match %r{</urlset>}, @response.body
    
    # Check required sitemap elements
    assert_match %r{<url>.*<loc>.*</loc>.*<lastmod>.*</lastmod>.*<changefreq>.*</changefreq>.*<priority>.*</priority>.*</url>}m, @response.body
  end

  test 'sitemap should include lastmod dates' do
    get sitemap_path(format: :xml)
    assert_response :success
    
    # Should include today's date for homepage
    assert_match %r{<lastmod>#{Time.current.strftime('%Y-%m-%d')}</lastmod>}, @response.body
    
    # Should include post's updated_at date
    assert_match %r{<lastmod>#{@published_post.updated_at.strftime('%Y-%m-%d')}</lastmod>}, @response.body
  end

  test 'sitemap should be accessible without authentication' do
    # This test ensures the sitemap works without signing in
    get sitemap_path(format: :xml)
    assert_response :success
    
    # Should not redirect to sign in page
    assert_not_includes @response.body, 'Sign In'
  end
end
