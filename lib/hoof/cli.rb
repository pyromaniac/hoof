require "thor"
require 'daemons'
require "hoof"

module Hoof
  class Cli < Thor
    include Thor::Actions

    default_task :start

    desc 'start', 'Starts hoof daemon'
    def start
      daemon 'start'
    end

    desc 'stop', 'Stops hoof daemon'
    def stop
      daemon 'stop'
    end

    desc 'restart', 'Restarts hoof daemon'
    def restart
      daemon 'restart'
    end

    desc 'init [NAME]', 'Initializes hoof for app in current directory'
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

    desc 'status', 'Lists hoof applications'
    def status
      control 'status'
    end

    desc 'install [TARGET]', 'Redirects http ports to hoof default ports with iptables'
    def install target = ''
      ext = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'ext'))
      puts "Successfully installed NSS library" if system "cd #{ext} && make && sudo make install"
      puts "Successfully added iptables rules" if system <<-E
        sudo iptables -t nat -I OUTPUT --source 0/0 --destination 127.0.0.1 -p tcp --dport 80 -j REDIRECT --to-ports #{Hoof.http_port} &&
        sudo iptables -t nat -I OUTPUT --source 0/0 --destination 127.0.0.1 -p tcp --dport 443 -j REDIRECT --to-ports #{Hoof.https_port}
      E
    end

    desc 'uninstall [TARGET]', 'Destroys hoof iptables redirecting rules'
    def uninstall target = ''
      ext = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'ext'))
      puts "Successfully uninstalled NSS library" if system "cd #{ext} && sudo make uninstall && make clean"
      puts "Successfully removed iptables rules" if system <<-E
        sudo iptables -t nat -D OUTPUT --source 0/0 --destination 127.0.0.1 -p tcp --dport 80 -j REDIRECT --to-ports #{Hoof.http_port} &&
        sudo iptables -t nat -D OUTPUT --source 0/0 --destination 127.0.0.1 -p tcp --dport 443 -j REDIRECT --to-ports #{Hoof.https_port}
      E
    end

  private

    def daemon *argv
      Daemons.run_proc 'hoof', :dir_mode => :normal, :dir => '/tmp', :log_output => true, :ARGV => argv.flatten do
        Hoof.start
      end
    end

    def control comand
      begin
        UNIXSocket.open(Hoof.sock) do |s|
          s.write comand
          puts s.read
        end
      rescue Errno::ECONNREFUSED
        puts 'Hoof is not running'
      end
    end

  end
end
