require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test 'should get show' do
    page = postables(:three) # This is a page from our fixtures
    get page_url(page)
    assert_response :success
  end
end
