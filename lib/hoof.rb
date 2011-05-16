require 'eventmachine'
require 'unicorn/launcher'
require 'http/parser'

require 'hoof/http_server'
require 'hoof/control_server'
require 'hoof/application'
require 'hoof/application_pool'

module Hoof

  def self.pool
    @pool ||= begin
      app_pool = Hoof::ApplicationPool.new
      app_pool.reload
      app_pool
    end
  end

  def self.find name
    pool[name]
  end

  def self.start
   EventMachine.epoll
   EventMachine::run do
     trap("TERM") { stop }
     trap("INT")  { stop }

     EventMachine::start_server "127.0.0.1", 3001, Hoof::HttpServer
     EventMachine::start_server sock, Hoof::ControlServer
   end
  end

  def self.stop
    pool.stop
    EventMachine.stop
  end

  def self.sock
    '/tmp/hoof.sock'
  end

end
