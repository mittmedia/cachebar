module CacheBar
  module DataStore
    class Memcached < AbstractDataStore

      def backup_key_name
        "api-cache:backup:#{api_name}:#{uri_hash}"
      end

      def response_exists?
        !client.get(cache_key_name).nil?
      end
      
      def get_response
        JSON.parse(client.get(cache_key_name), symbolize_names: true)
      end
      
      def store_response(response_hash, interval)
        client.set(cache_key_name, response_hash.to_json, interval)
      end
      
      def backup_exists?
        !client.get(backup_key_name).nil?
      end
      
      def get_backup
        JSON.parse(client.get(backup_key_name), symbolize_names: true)
      end
      
      def store_backup(response_hash, interval)
        client.set(backup_key_name, response_hash.to_json)
      end
    end
  end
end