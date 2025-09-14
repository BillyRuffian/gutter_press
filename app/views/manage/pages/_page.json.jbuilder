json.extract! page, :id, :title, :published_at, :user_id, :created_at, :updated_at
json.url manage_page_url(page, format: :json)
