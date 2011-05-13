require 'eventmachine'
require 'unicorn'

require 'lib/hoof/http_server'
require 'lib/hoof/application'
require 'lib/hoof/application_pull'

module Hoof

  def self.pull
    @pull ||= Hoof::ApplicationPull.new
  end

  def self.application name
    pull.add name
  end

  def self.start
   EventMachine.epoll
   EventMachine::run do
     trap("TERM") { Hoof.stop }
     trap("INT")  { Hoof.stop }

     EventMachine::start_server "127.0.0.1", 3001, Hoof::HttpServer
   end
  end

  def self.stop
    EventMachine.stop
    pull.stop
  end

end
