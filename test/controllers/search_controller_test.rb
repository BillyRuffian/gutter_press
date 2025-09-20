require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
  end

  test "should get index" do
    get search_url
    assert_response :success
  end

  test "should search for posts" do
    post = postables(:first_post) # Using postables fixture
    get search_url, params: { q: post.title }
    assert_response :success
  end

  test "should handle empty search query" do
    get search_url, params: { q: '' }
    assert_response :success
  end

  test "should handle search with no results" do
    get search_url, params: { q: 'nonexistentquerythatreturnsnothing' }
    assert_response :success
  end
end
