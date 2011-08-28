module Hoof
  class HttpServer < EventMachine::Connection
    include EventMachine::HttpServer

    def post_init
      super
      no_environment_strings
      @buffer = ''
    end

    def receive_data data
      @buffer << data
      super
    end

    def process_http_request
      p 'DATA'
      p @buffer
      begin
        host = @http_headers.scan(/Host:\s*([-a-zA-z.]*)\000/)[0][0].gsub(/:\d+$/, '')
        close_connection and return unless host =~ /.dev$/

        name = host.split('.')[-2]
        application = Hoof.find name

        if application
          if application.static_file? @http_path_info
            puts "Serve static #{host}#{@http_request_uri}"
            send_data application.serve_static(@http_path_info)
            close_connection_after_writing
          else
            application.start
            puts "Serve #{host}#{@http_request_uri}"
            EventMachine.defer(proc {
              application.serve @buffer
            }, proc { |result|
              send_data result
              close_connection_after_writing
            })
          end
        else
          close_connection
        end
      rescue => e
        puts e.message
        puts e.backtrace.join("\n")
        close_connection
      end
    end

  end
end
