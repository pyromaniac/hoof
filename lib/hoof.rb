require 'eventmachine'
require 'unicorn/launcher'
require 'http/parser'

require 'hoof/http_server'
require 'hoof/application'
require 'hoof/application_pool'

module Hoof

  def self.pool
    @pool ||= Hoof::ApplicationPool.new
  end

  def self.application name
    pool.add name
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
    pool.stop
  end

end
