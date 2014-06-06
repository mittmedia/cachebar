class MockDataStore < CacheBar::DataStore::AbstractDataStore
  def backup_key_name
    "api-cache:backup:#{api_name}:#{uri_hash}"
  end

  def response_exists?

  end

  def get_response

  end

  def store_response(response_body, interval)

  end

  def backup_exists?

  end

  def get_backup

  end

  def store_backup(response_body)

  end

  def update_async(url, interval)

  end
end