module HTTParty
  describe HTTPCache do
    describe 'data_store_class=' do
      it 'should be able to use a symbol of an existing pre-packaged data store' do
        HTTParty::HTTPCache.data_store_class = :redis
        expect(CacheBar::DataStore::Redis).to eq(HTTParty::HTTPCache.data_store_class)
      end

      it 'should be able to use a class of an existing pre-packaged data store' do
        HTTParty::HTTPCache.data_store_class = MockDataStore
        expect(MockDataStore).to eq(HTTParty::HTTPCache.data_store_class)
      end

      it 'should raise exception if something else is passed in' do
        expect{HTTParty::HTTPCache.data_store_class = 'data_store'}.to raise_error(ArgumentError)
      end
    end

    describe 'perform_with_caching' do
      pending "Method needs refactor"
    end

    describe 'cacheable?' do
      before :each do
        setup_cachebar
        turn_on_caching
      end

      it 'returns false if caching is disabled' do
        turn_off_caching
        expect(@cached_request.send(:cacheable?)).to eq(false)
      end

      it 'returns true if caching is enabled' do
        expect(@cached_request.send(:cacheable?)).to eq(true)
      end

      it 'return false if host not in apis' do
        expect(@request.send(:cacheable?)).to eq(false)
      end

      it 'return false in host not in apis' do
        expect(@post_request.send(:cacheable?)).to eq(false)
      end
    end

    describe 'graceable?' do
      before :each do
        setup_cachebar
        turn_on_caching
        turn_on_grace
      end

      it 'returns true if grace is turned on' do
        expect(@cached_request).to receive(:backup_exists?).and_return(true)
        expect(@cached_request.send(:graceable?)).to eq(true)
      end

      it 'returns false if grace is turned off' do
        turn_off_grace
        expect(@cached_request.send(:graceable?)).to eq(false)
      end

      it 'returns false if there is no backup' do
        turn_on_grace
        expect(@cached_request).to receive(:backup_exists?).and_return(false)
        expect(@cached_request.send(:graceable?)).to eq(false)
      end

      it 'returns false if request cache option is false' do
        turn_on_grace
        @cached_request.options[:cache] = false
        expect(@cached_request).to receive(:backup_exists?).and_return(true)
        expect(@cached_request.send(:graceable?)).to eq(false)
      end
    end

    describe 'response_from' do
      it 'returns a HTTParty::Response' do
        mock_requests
        expect(@request.response_from({body: "", code: 200}).class.name).to eq("HTTParty::Response")
      end

      describe 'parsed_response' do
        pending "Seems like parsed_response returns String if cache hit and Hash if cache miss, need to fix this eventually"
        it 'returns Hash when cache hit' do

        end

        it 'returns Hash when cache miss' do

        end
      end
    end

    describe 'retrieve_and_store_backup' do
      pending "Method needs refactor"
    end

    describe 'normalized_uri' do
      it 'exists' do
        mock_requests
        @request.respond_to?(:normalized_uri)
      end
    end

    describe 'uri_hash' do
      it 'exists' do
        mock_requests
        @request.respond_to?(:uri_hash)
      end
    end

    describe 'store_in_cache' do
      it 'exists' do
        mock_requests
        @request.respond_to?(:store_in_cache)
      end
    end

    describe 'update_cache_async' do
      it 'exists' do
        mock_requests
        @request.respond_to?(:update_cache_async)
      end
    end

    describe 'data_store' do
      it 'exists' do
        mock_requests
        @request.respond_to?(:data_store)
      end
    end

    describe 'api_key_name' do
      it 'exists' do
        mock_requests
        @request.respond_to?(:api_key_name)
      end
    end

    describe 'log_message' do
      it 'exists' do
        mock_requests
        @request.respond_to?(:log_message)
      end
    end

    describe 'timeout' do
      before do
        mock_requests
      end
      it 'exists' do
        @request.respond_to?(:timeout)
      end

      it 'raises Timeout::Error after interval' do
        expect{ @request.timeout(0.001) { sleep(0.002) }}.to raise_error(Timeout::Error)
      end

      it 'does not raise Timeout::Error before interval' do
        expect{ @request.timeout(0.002) { sleep(0.001) }}.to_not raise_error
      end
    end
  end
end