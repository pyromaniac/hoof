module Hoof
  class HttpServer < EventMachine::Connection

    def receive_data data
      parser = Http::Parser.new
      parser.parse data
      host = parser.headers["HOST"].gsub(/:\d+$/, '')

      close_connection and return unless host =~ /.dev$/

      name = host.gsub(/.dev$/, '')
      application = Hoof.find name

      if application
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
      else
        close_connection
      end
    end

  end
end
