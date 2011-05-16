module Hoof
  class HttpServer < EventMachine::Connection

    def receive_data data
      begin
        parser = Http::Parser.new
        parser.parse data

        host = parser.headers["HOST"].gsub(/:\d+$/, '')

        close_connection and return unless host =~ /.dev$/

        name = host.gsub(/.dev$/, '')
        application = Hoof.find name

        if application
          application.start
          puts "Serve #{host}#{parser.path}"
          EventMachine.defer(proc {
            application.serve data
          }, proc { |result|
            send_data result
            close_connection_after_writing
          })
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
