# Ruby Web Server One Liners

Ruby ships with a fully functional, extensible, fairly featureful web server
implementation in it's standard library. This server is called Webrick. Here
are a few simple one liners that leverage it:

```sudo ruby -rwebrick -e 'WEBrick::HTTPServer.new.start'```

```ruby -run -e httpd -- -p 8080```

One can also leverage Rack + Webrick for a simplistic application server:

```ruby -rrack -e "Rack::Handler::WEBrick.run Proc.new {|e| [ '200', { 'Content-Type' =< 'text/html' }, [ 'Woo! One line!' ] ] }"```

Or leverage another Ruby websever altogether:

```ruby -rrack -e "include Rack; Handler::Thin.run Builder.new { run Directory.new '' }"