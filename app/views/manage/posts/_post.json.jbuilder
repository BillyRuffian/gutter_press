json.extract! post, :id, :title, :published_at, :user_id, :created_at, :updated_at
json.url manage_post_url(post, format: :json)
