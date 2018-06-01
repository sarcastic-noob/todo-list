# frozen_string_literal: true

require 'spec_helper'
require 'todo'
require 'rack/test'

RSpec.describe Todo do
  include Rack::Test::Methods
  def app
    Todo::TodoApp.new
  end

  context 'check for the version'
  it 'has a version number' do
    expect(Todo::VERSION).not_to be nil
  end

  before :all do
    @connection = Database.connection('127.0.0.1', 5432, nil, nil, 'postgres', 'postgres', 'ggwp')
    @connection.exec('DROP TABLE IF EXISTS list')
    @connection.exec('create table list(id serial primary key, message text)')
    @connection.exec("insert into list(message) values ('test_task')")
    @connection.exec("insert into list(message) values ('test_task2')")
  end

  context 'GET API' do
    it 'should return 200 response code' do
      get '/todo'
      expect(last_response.status). to eq 200
    end
    it 'should return JSON' do
      get '/todo'
      expect(last_response.headers['Content-Type']).to eql('application/json')
    end
    it 'should match to actual resource in database' do
      get '/todo'
      parsed_response = JSON.parse(last_response.body)
      rows = @connection.exec('SELECT * FROM list')
      expect(rows[0]['id']).to eql(parsed_response[0]['id'])
      expect(rows[0]['message']).to eql(parsed_response[0]['message'])
      expect(rows[1]['id']).to eql(parsed_response[1]['id'])
      expect(rows[1]['message']).to eql(parsed_response[1]['message'])
    end
  end

  context 'POST API' do
    it 'should return response code 201' do
      fields = '{"message":"post_test_message1"}'
      post '/todo', JSON.parse(fields)
      expect(last_response.status). to eq 201
    end
    it 'should return JSON' do
      fields = '{"message":"post_test_message2"}'
      post '/todo', JSON.parse(fields)
      expect(last_response.headers['Content-Type']).to eql('application/json')
    end
    it 'should match to actual resource in database' do
      fields = '{"message":"post_test_message3"}'
      post '/todo', JSON.parse(fields)
      parsed_response = JSON.parse(last_response.body)
      rows = @connection.exec('SELECT * FROM list')
      count_rows = rows.ntuples
      expect(rows[count_rows - 1]['id']).to eql(parsed_response[0]['id'])
      expect(rows[count_rows - 1]['message']).to eql(parsed_response[0]['message'])
    end
    it 'should increase number of rows in database by 1 unit' do
      fields = '{"message":"post_test_message4"}'
      count = 'SELECT COUNT(*) FROM list'
      count_rows_before = @connection.exec(count)
      count_rows_before = count_rows_before[0]['count'].to_i
      post '/todo', JSON.parse(fields)
      count_rows_after = @connection.exec(count)
      count_rows_after = count_rows_after[0]['count'].to_i
      expect(count_rows_after - count_rows_before).to eql 1
    end
  end

  context 'PUT API' do
    it 'should give a response 204 for existing resource' do
      fields = '{"message":"updated_message"}'
      put '/todo/1', JSON.parse(fields)
      expect(last_response.status).to eq 204
    end
    it 'should give a response 400 for non-existing resource' do
      fields = '{"message":"updated_message"}'
      put '/todo/0', JSON.parse(fields)
      expect(last_response.status).to eq 400
    end
    it 'should actully update that resource in database' do
      fields = '{"message":"updated_message_for_id_2"}'
      put '/todo/2', JSON.parse(fields)
      select_query = 'select * from list where id=2'
      result = @connection.exec(select_query)
      expect(result[0]['message']).to eql('updated_message_for_id_2')
    end
    it 'should not update any other resource in database' do
      select_query = 'select * from list where id!=3'
      before_query_rows = @connection.exec(select_query)
      fields = '{"message":"updated_message_for_id_3"}'
      put '/todo/3', JSON.parse(fields)
      after_query_rows = @connection.exec(select_query)
      expect(before_query_rows.ntuples).to equal(after_query_rows.ntuples)
      i = 0
      while i < before_query_rows.ntuples
        expect(before_query_rows[i]['id']).to eql(after_query_rows[i]['id'])
        expect(before_query_rows[i]['message']).to eql(after_query_rows[i]['message'])
        i += 1
      end
    end
    it 'should not update any resource in database for invalid PUT' do
      select_query = 'select * from list where id!=0'
      before_query_rows = @connection.exec(select_query)
      fields = '{"message":"updated_message_for_id_0"}'
      put '/todo/0', JSON.parse(fields)
      after_query_rows = @connection.exec(select_query)
      expect(before_query_rows.ntuples).to equal(after_query_rows.ntuples)
      i = 0
      while i < before_query_rows.ntuples
        expect(before_query_rows[i]['id']).to eql(after_query_rows[i]['id'])
        expect(before_query_rows[i]['message']).to eql(after_query_rows[i]['message'])
        i += 1
      end
    end
  end

  context 'DELETE API' do
    it 'should give 204 for valid delete' do
      delete '/todo/1'
      expect(last_response.status).to eql 204
    end
    it 'should give a response 404 for non-existing resource' do
      delete '/todo/0'
      expect(last_response.status).to eq 404
    end
    it 'should actully delete that resource in database' do
      delete '/todo/4'
      select_query = 'select count(*) from list where id=4'
      result = @connection.exec(select_query)
      expect(result[0]['count']).to eql('0')
    end
  end
end
