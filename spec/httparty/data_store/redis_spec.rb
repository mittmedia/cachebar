module CacheBar::DataStore
  describe Redis do
    describe 'CacheBar::DataStore::Redis' do
      it 'initialize with api_name and uri_hash' do
        datastore = CacheBar::DataStore::Redis.new('api_name', 'uri_hash')
        expect(datastore.api_name).to eq('api_name')
        expect(datastore.uri_hash).to eq('uri_hash')
      end
    end
    describe 'methods' do
      before do
        @client = double()
        CacheBar::DataStore::Redis.client = @client
        @datastore = CacheBar::DataStore::Redis.new('twitter', 'URIHASH')
      end

      describe '#response_exists?' do
        it 'returns true if the resource is in redis' do
          expect(@client).to receive(:exists).with("api-cache:twitter:URIHASH").and_return(true)
          expect(@datastore.response_exists?).to eq(true)
        end

        it 'returns false if the resource is not in redis' do
          expect(@client).to receive(:exists).with("api-cache:twitter:URIHASH").and_return(false)
          expect(@datastore.response_exists?).to eq(false)
        end
      end

      describe '#store_response' do
        it 'store data in redis' do
          expect(@client).to receive(:set).with("api-cache:twitter:URIHASH", {code: 200, body: ""}.to_json).and_return(true)
          expect(@client).to receive(:expire).and_return(true)
          @datastore.store_response({code: 200, body: ""}, 10)
        end

        it 'sets expires on cache key' do
          expect(@client).to receive(:set).and_return(true)
          expect(@client).to receive(:expire).with("api-cache:twitter:URIHASH", 10).and_return(true)
          @datastore.store_response({code: 200, body: ""}, 10)
        end
      end
      describe '#backup_exists?' do
        it 'returns true if the resource is in the redis backup hash' do
          expect(@client).to receive(:exists).with("api-cache:twitter").and_return(true)
          expect(@client).to receive(:hexists).with("api-cache:twitter", "URIHASH").and_return(true)
          expect(@datastore.backup_exists?).to be true
        end

        it 'returns false if the resource is not in the redis backup hash' do
          expect(@client).to receive(:exists).with("api-cache:twitter").and_return(true)
          expect(@client).to receive(:hexists).with("api-cache:twitter", "URIHASH").and_return(false)
          expect(@datastore.backup_exists?).to be false
        end

        it 'returns false if the backup hash does not exist' do
          expect(@client).to receive(:exists).with("api-cache:twitter").and_return(false)
          expect(@datastore.backup_exists?).to be false
        end
      end

      describe '#get_response' do
        it 'retrieves the response from the cache' do
          expect(@client).to receive(:get).with("api-cache:twitter:URIHASH").and_return({code:200, body:""}.to_json)
          expect(@datastore.get_response).to eq({code:200, body:""})
        end
      end

      describe '#get_backup' do
        it 'retrieves the response from the backup hash' do
          expect(@client).to receive(:hget).with("api-cache:twitter", "URIHASH").and_return({code:200, body:""}.to_json)
          expect(@datastore.get_backup).to eq({code:200, body:""})
        end
      end

      describe '#store_backup' do
        it 'stores the response in the backup hash' do
          expect(@client).to receive(:hset).with("api-cache:twitter", "URIHASH", {code:200, body:""}.to_json).and_return(true)
          @datastore.store_backup({code:200, body:""})
        end
      end
    end
  end
end