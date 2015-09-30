module CacheBar
  module DataStore
    class AbstractDataStore
      class_attribute :client

      attr_reader :api_name, :uri_hash

      def initialize(api_name, uri_hash)
        @api_name = api_name
        @uri_hash = uri_hash
      end

      def response_exists?
        raise NotImplementedError, 'Implement response_exists? in sub-class'
      end

      def get_response
        raise NotImplementedError, 'Implement get_response in sub-class'
      end

      def store_response(response_hash, interval)
        raise NotImplementedError, 'Implement store_response in sub-class'
      end

      def backup_exists?
        raise NotImplementedError, 'Implement backup_exists? in sub-class'
      end

      def get_backup
        raise NotImplementedError, 'Implement get_backup in sub-class'
      end

      def store_backup(response_hash, interval)
        raise NotImplementedError, 'Implement store_backup in sub-class'
      end

      def update_async(url, interval, headers)
        raise NotImplementedError, 'Implement update_async in sub-class'
      end

      private

      def cache_key_name
        "api-cache:#{api_name}:#{uri_hash}"
      end

      def backup_key_name
        "api-cache:backup:#{api_name}"
      end
    end
  end
end
