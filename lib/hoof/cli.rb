require "thor"
require 'daemons'
require "hoof"

module Hoof
  class Cli < Thor

    default_task :start

    desc "start", "Starts hoof daemon"
    def start
      daemon 'start'
    end

    desc "stop", "Stops hoof daemon"
    def stop
      daemon 'stop'
    end

    #desc "list", "Lists started applications"
    #def list
    #end

  private

    def daemon *argv
      Daemons.run_proc 'hoof', :dir_mode => :normal, :dir => '/tmp', :log_output => true, :ARGV => argv.flatten do
        Hoof.start
      end
    end

  end
end
