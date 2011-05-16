module Hoof
  class HttpServer < EventMachine::Connection

    def receive_data data
      parser = Http::Parser.new
      parser.parse data
      host = parser.headers["HOST"].gsub(/:\d+$/, '')

      close_connection and return unless host =~ /.dev$/

      name = host.gsub(/.dev$/, '')
      path = parser.path.split('?', 2)[0]

      application = Hoof.find name

      if application
        if application.static_file? path
          puts "Serve static #{host}#{parser.path}"
          send_data application.serve_static(path)
          close_connection_after_writing
        else
          begin
            application.start
            puts "Serve #{host}#{parser.path}"
            EventMachine.defer(proc {
              application.serve data
            }, proc { |result|
              send_data result
              close_connection_after_writing
            })
          rescue
            puts "Failed to serve #{name}"
          end
        end
      else
        close_connection
      end
    end

  end
end
