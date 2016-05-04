require 'mime-types'
require 'time'
require 'eventmachine'
require 'evma_httpserver'

trap 'INT' do; exit end # in a real server, you want more more cleanup than this

class MyHttpServer < EM::Connection
  include EM::HttpServer

  DOCROOT = Dir.pwd

  def post_init
    super
    no_environment_strings
  end

  def process_http_request
    response = EM::DelegatedHttpResponse.new(self)
    path = File.join( DOCROOT, @http_request_uri )
    if FileTest.exist?( path ) and FileTest.file?( path ) and File.expand_path( path ).index( DOCROOT ) == 0
      response.status = 200 
      response.content_type MIME::Types.type_for( path ).last.to_s
      response.content = File.read( path )
      response.send_response
    else
      response.status = 200
      response.content = "The resource #{path} could not be found."
      response.send_response
    end
  end

  def final_headers
    "Date: #{Time.now.httpdate}\r\nConnection: close\r\n\r\n"
  end

end

EM.run {
  EM.start_server '0.0.0.0', 80, MyHttpServer
}
