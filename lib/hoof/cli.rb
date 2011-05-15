require "thor"
require 'daemons'
require "hoof"

module Hoof
  class Cli < Thor
    include Thor::Actions

    default_task :start

    desc 'hoof start', 'Starts hoof daemon'
    def start
      daemon 'start'
    end

    desc 'hoof stop', 'Stops hoof daemon'
    def stop
      daemon 'stop'
    end

    desc 'hoof init [NAME]', 'Initializes hoof for app in current directory'
    long_desc <<-D
      Initializes hoof for current directory application.
      This task creates symlink in ~/.hoof and adds unicorn to
      your application Gemfile.
      So do not forget to bundle it again.
    D
    def init name = nil
      name ||= File.basename Dir.getwd
      create_link File.expand_path(File.join("~/.hoof", name)), '.'
      append_to_file 'Gemfile', "\ngem 'unicorn'"
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
