require 'http/parser'

module Hoof
  class HttpServer < EventMachine::Connection
    attr_accessor :applications

    def initialize *args
      super
      @applications = {}
    end

    def receive_data data
      parser = Http::Parser.new
      parser.parse data

      host = parser.headers["HOST"].gsub(/:\d+$/, '')
      if host =~ /.dev$/
        name = host.gsub(/.dev$/, '')
        application = Hoof.application name

        if application.static? parser.path.split('?', 2)[0]
          send_data application.serve_static parser.path.split('?', 2)[0]
          close_connection_after_writing
        else
          p "serve #{host}#{parser.path}"
          EventMachine.defer(proc {
            application.serve(data)
          }, proc { |result|
            send_data result
            close_connection_after_writing
          })
        end
      end
    end

  end
end
