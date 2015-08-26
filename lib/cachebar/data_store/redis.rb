require 'resque'
module CacheBar
  module DataStore
    class Redis < AbstractDataStore
      def response_exists?
        client.exists(cache_key_name)
      end
      
      def get_response
        JSON.parse(client.get(cache_key_name), symbolize_names: true)
      end
      
      def store_response(response_hash, interval)
        client.setex(cache_key_name, interval, response_hash.to_json)
      end
      
      def backup_exists?
        client.exists(backup_key_name) && client.hexists(backup_key_name, uri_hash)
      end
      
      def get_backup
        JSON.parse(client.hget(backup_key_name, uri_hash), symbolize_names: true)
      end

      def store_backup(response_hash, interval)
        client.hset(backup_key_name, uri_hash, response_hash.to_json)
      end

      def update_async(url, interval, headers)
        HTTParty::HTTPCache.logger.debug("[HTTPCache]: Update async #{cache_key_name}-#{url}")
        Resque.enqueue(UpdateRedisCache, cache_key_name, backup_key_name, uri_hash, url, interval, headers)
      end

      class UpdateRedisCache
        @queue = :update_redis_cache
        def self.perform(cache_key_name, backup_key_name, uri_hash, url, interval, headers)
          HTTParty::HTTPCache.logger.debug "[HTTPCache]: Updating #{url}"
          response_body = HTTParty.get(url, {cache: false, headers: headers}).parsed_response
        end
      end
    end
  end
end
