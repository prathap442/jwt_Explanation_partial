json.extract! user, :id, :firstname, :lastname, :token, :token_expiry, :created_at, :updated_at
json.url user_url(user, format: :json)
