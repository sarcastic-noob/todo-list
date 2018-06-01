require 'sinatra'
require 'pg'
require 'json'
require_relative './postgre'

module Todo
  class TodoApp < Sinatra::Base
    def initialize
      @connect = Database.connection('127.0.0.1', 5432, nil, nil, 'postgres', ENV['user'], ENV['password'])
      super
    end
    get '/' do
      content_type 'text/html'
      '<h1>Welcome to TODO APP</h1>'
    end
    before do
      content_type :json
    end

    get '/todo' do
      list = @connect.exec('select * from list')
      result_array = []
      list.each do |row|
        result_array.push(row)
      end
      halt 200, result_array.to_json
    end

    post '/todo' do
      message = @params[:message]
      insert_query = "insert into list(message) values ('#{message}') returning id, message;"
      result_row = @connect.exec(insert_query)
      result_array = []
      result_array.push(result_row[0])
      halt 201, result_array.to_json
    end

    put '/todo/:id' do
      id = @params[:id]
      message = @params[:message]
      count_query = "SELECT COUNT(*) FROM list where id='#{id}'"
      count_rows = @connect.exec(count_query)
      count = count_rows[0]['count'].to_i
      if count.zero?
        halt 400
      else
        @connect.exec("update list set message ='#{message}' where id='#{id}'")
        halt 204
      end
    end

    delete '/todo/:id' do
      id = @params[:id]
      count_query = "SELECT COUNT(*) FROM list where id='#{id}'"
      count_rows = @connect.exec(count_query)
      count = count_rows[0]['count'].to_i
      if count.zero?
        halt 404
      else
        @connect.exec("delete from list where id='#{id}'")
        halt 204
      end
    end
  end
end
