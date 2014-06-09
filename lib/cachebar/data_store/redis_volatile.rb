require 'resque'
module CacheBar
  module DataStore
    class RedisVolatile < Redis
      def backup_key_name
        "api-cache:backup:#{api_name}:#{uri_hash}"
      end

      def backup_exists?
        client.exists(backup_key_name)
      end
      
      def get_backup
        JSON.parse(client.get(backup_key_name), symbolize_names: true)
      end

      def store_backup(response_hash, interval)
        client.setex(backup_key_name, interval, response_hash.to_json)
      end
    end
  end
end