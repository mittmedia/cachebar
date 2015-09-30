module CacheBar
  describe "register_api_to_cache" do
    it 'should raise ArgumentError if host is blank' do
      expect{ CacheBar.register_api_to_cache('', {key_name: 'api', expire_in: 1})}.to raise_error(ArgumentError)
    end

    it 'should raise ArgumentError if no :key_name' do
      expect{ CacheBar.register_api_to_cache('api.org', {expire_in: 1})}.to raise_error(ArgumentError)
    end

    it 'should raise ArgumentError if no :expire_in ' do
      expect{ CacheBar.register_api_to_cache('api.org', {key_name: 'api'})}.to raise_error(ArgumentError)
    end

    it 'should add host to apis if valid' do
      expect(CacheBar.register_api_to_cache('api.org', {key_name: 'api', expire_in: 1})).to eq({key_name: 'api', expire_in: 1})
      expect(HTTParty::HTTPCache.apis).to include('api.org')
    end
  end

  describe ClassMethods do
    describe 'caches_api_responses' do
      pending "I haven't had time to look into what it does"
    end
  end

  describe 'using HTTParty with CacheBar' do
    describe 'and gets a good response' do
      before do
        mock_data_store
        setup_cachebar
        turn_on_caching
        VCR.insert_cassette('good_response')
      end

      after do
        VCR.eject_cassette
      end
      it 'calls data_store#store_response with response hash and expiration' do
        #TODO: I'd like to verify those return values, but how?
        expect_any_instance_of(HTTParty::Request).to receive(:cacheable?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:response_exists?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:graceable?).and_call_original

        expect_any_instance_of(HTTParty::Request).to receive(:store_in_cache).with(hash_including(:code, :body)).and_call_original
        expect_any_instance_of(MockDataStore).to receive(:store_response).with(hash_including(:code, :body), 5)
        TwitterAPI.user_timeline('viget')
      end

      it 'calls data_store#store_backup with response hash' do
        #TODO: I'd like to verify those return values, but how?
        expect_any_instance_of(HTTParty::Request).to receive(:cacheable?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:response_exists?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:graceable?).and_call_original

        expect_any_instance_of(HTTParty::Request).to receive(:store_in_backup).with(hash_including(:code, :body)).and_call_original
        expect_any_instance_of(MockDataStore).to receive(:store_backup)
        TwitterAPI.user_timeline('viget')
      end

      it 'returns a HTTParty::Response' do
        #TODO: I'd like to verify those return values, but how?
        expect_any_instance_of(HTTParty::Request).to receive(:cacheable?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:response_exists?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:graceable?).and_call_original
        expect(TwitterAPI.user_timeline('viget').class).to eq(HTTParty::Response)
      end
    end
    describe 'and response exists' do
      before do
        mock_data_store
        setup_cachebar
        turn_on_caching
        VCR.insert_cassette('good_response')
      end

      after do
        VCR.eject_cassette
      end

      it 'returns a HTTParty::Response' do
        expect_any_instance_of(HTTParty::Request).to receive(:cacheable?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:response_exists?).and_return(true)
        expect_any_instance_of(HTTParty::Request).to receive(:get_response).and_return({code: 200, body:{status:"OK"}.to_json})
        expect_any_instance_of(HTTParty::Request).to receive(:response_from).and_call_original
        response = TwitterAPI.user_timeline('viget')
        expect(response.class).to eq(HTTParty::Response)
      end
    end

    describe 'and response timeouts' do
      it 'retrives from backup if it exists' do
        mock_data_store
        setup_cachebar
        turn_on_caching

        expect_any_instance_of(HTTParty::Request).to receive(:cacheable?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:response_exists?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:backup_exists?).and_return(true)
        expect_any_instance_of(HTTParty::Request).to receive(:get_backup).and_return({code: 200, body:{status:"OK"}.to_json})
        expect_any_instance_of(HTTParty::Request).to receive(:response_from).and_call_original

        expect_any_instance_of(HTTParty::Request).to receive(:timeout).and_raise(Timeout::Error)
        response = TwitterAPI.user_timeline('viget')
        expect(response.class).to eq(HTTParty::Response)
        expect(response.parsed_response["status"]).to eq("OK")
      end

      it 'stores backup in cache if it exists' do
        mock_data_store
        setup_cachebar
        turn_on_caching

        expect_any_instance_of(HTTParty::Request).to receive(:cacheable?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:response_exists?).and_call_original
        expect_any_instance_of(HTTParty::Request).to receive(:backup_exists?).and_return(true)
        expect_any_instance_of(HTTParty::Request).to receive(:get_backup).and_return({code: 200, body:{status:"OK"}.to_json})
        expect_any_instance_of(HTTParty::Request).to receive(:store_in_cache).with({code: 200, body:{status:"OK"}.to_json}, 300).and_call_original
        expect_any_instance_of(MockDataStore).to receive(:store_response).with(hash_including(:code, :body), 300)

        expect_any_instance_of(HTTParty::Request).to receive(:timeout).and_raise(Timeout::Error)
        TwitterAPI.user_timeline('viget')
      end
    end
  end
end