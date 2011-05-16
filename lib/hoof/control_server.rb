module Hoof
  class ControlServer < EventMachine::Connection

    def receive_data data
      p "comand #{data}"
      result = send data
      send_data result
      close_connection_after_writing
    end

    def status
      Hoof.pool.map do |(name, app)|
        status = app.running? ? "[\033[1;32mrunning\033[0m]" : "[\033[1;31mstopped\033[0m]"
        "  #{app.pid if app.running?}\t#{name}\t\t\t#{status}"
      end.join("\n")
    end

  end
end
