# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/sse'
require 'sqlite3'
require_relative 'settings'
require 'ld-eventsource'

class Server < Sinatra::Base
  include Sinatra::SSE

  set :public_folder, __dir__ + '/frontend/9chan/build/'

  db = SQLite3::Database.new(DB_NAME)

  get '/' do
    content_type 'html'
    send_file 'frontend/9chan/build/index.html'
  end

  post '/api/messages' do
    content_type :json

    request.body.rewind
    data = JSON.parse request.body.read

    db.execute "insert into messages(content) values (?)", [data['content']]

    return data.to_json
  end

  get '/api/messages' do
    content_type :json

    result = db.execute "select * from messages"

    result = result.map do |pair|
      {"id" => pair[0], "content" => pair[1]}
    end

    return result.to_json
  end

  get '/api/messages/from/:n' do
    n = params['n'].to_i

    result = (db.execute "select * from messages")

    return [].to_json if result.size <= n

    result = result[n..].map do |pair|
      {"id" => pair[0], "content" => pair[1]}
    end

    return result.to_json
  end

  get '/stream' do
    sse_stream do |out|
      pre_messages = db.execute "select * from messages"
      EM.add_periodic_timer(1) do
        messages = db.execute "select * from messages"
        out.push :data => {"date" => Time.now.to_s, "type" => "update", "display_name" => CHANNEL_NAME, "url" => "http://localhost:9292/"}.to_json if pre_messages != messages
        pre_messages = messages
      end
    end
  end

  def mkevent(url, out)
    SSE::Client.new(url) do |c|
      c.on_event do |e|
        out.push :data => e.data
      end
    end
  end

  get '/api/subscribes/stream' do
    sse_stream do |out|
      clients = SUBSCRIBES.map { mkevent(_1, out) }
    end
  end
end
