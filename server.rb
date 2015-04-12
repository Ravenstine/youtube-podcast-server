require_relative './environment'

PROJECT_ROOT = Dir.pwd

class Server < EM::HttpServer::Server

  def process_http_request
    params = query_string_to_params(@http_query_string)
    response = EM::DelegatedHttpResponse.new(self)
    response.status = 200
    response.headers['Content-Type'] = 'text/xml'
    EM.defer proc{
      Playlist.new(params['id']).to_podcast
    }, proc{ |result|
      response.content = result
      response.send_response
    }
  end

  def http_request_errback e
    puts e.inspect
  end
private
  def query_string_to_params query_string
    query_string.split("&").map{|x| {x.split("=")[0] => x.split("=")[1]}}.first rescue {}
  end
end


EM::run do
  EM::start_server("0.0.0.0", 1337, Server)
end