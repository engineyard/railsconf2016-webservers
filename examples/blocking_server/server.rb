require 'socket'
require 'mime-types'
require 'time'
trap 'INT' do; exit end # in a real server, you want more more cleanup than this

DOCROOT = Dir.pwd
CANNED_OK = "HTTP/1.0 200 OK\r\n"
CANNED_NOT_FOUND = "HTTP/1.0 404 Not Found\r\n"
CANNED_BAD_REQUEST = "HTTP/1.0 400 Bad Request\r\n"

def run( host = '0.0.0.0', port = '8080' )
  server = TCPServer.new( host, port )

  while connection = server.accept
    request = get_request connection
    response = handle request

    connection.write response
    connection.close
  end
end

def get_request connection
  r = ''
  while line = connection.gets
    r << line
    break if r =~ /\r\n\r\n/m
  end

  if r =~ /^(\w+) +(?:\w+:\/\/([^ \/]+))?(([^ \?\#]*)\S*) +HTTP\/(\d\.\d)/
    request_method = $1
    unparsed_uri = $3
    uri = $4.empty? ? nil : $4
    http_version = $5
    name = $2 ? $2.intern : nil

    uri = uri.tr( '+', ' ' ).
        gsub( /((?:%[0-9a-fA-F]{2})+)/n ) { [$1.delete( '%' ) ].pack( 'H*' ) } if uri.include?('%')

    [ request_method, http_version, name, unparsed_uri, uri ]
  else
    nil
  end

end

def handle request
  if request
    process request
  else
    CANNED_BAD_REQUEST + final_headers
  end
end

def process request
  # This server is stupid. For any request method, and http version, it just tries to serve a static file.
  path = File.join( DOCROOT, request.last )
  if FileTest.exist?( path ) and FileTest.file?( path ) and File.expand_path( path ).index( DOCROOT ) == 0
    CANNED_OK +
        "Content-Type: #{MIME::Types.type_for( path )}\r\n" +
        "Content-Length: #{File.size( path )}\r\n" +
        "Last-Modified: #{File.mtime( path )}\r\n" +
        final_headers +
        File.read( path )
  else
    CANNED_NOT_FOUND + final_headers
  end
end

def final_headers
  "Date: #{Time.now.httpdate}\r\nConnection: close\r\n\r\n"
end

run