module Hoof
  class Application
    attr_accessor :root, :app, :name

    def initialize name
      @name = name
      @root = File.readlink(File.expand_path(File.join("~/.hoof/", name)))
    end

    def start
      unless running?
        rvmrc = ""
        if File.exists?(root + '/.rvmrc')
          rvmrc = File.read(root + '/.rvmrc').chomp
          rvmrc << " exec "
        else
          load_rvm
        end
        system "cd #{root} && #{rvmrc}bundle exec unicorn_rails -c #{File.join(File.dirname(__FILE__), 'unicorn_config.rb')} -l #{sock} -D"
      end
    end

    def load_rvm
      if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
        rvm_path     = File.dirname(File.dirname(ENV['MY_RUBY_HOME']))
        rvm_lib_path = File.join(rvm_path, 'lib')
        $LOAD_PATH.unshift rvm_lib_path
        require 'rvm'

        RVM.use_from_path! root
      end
    end

    def running?
      Daemons::Pid.running? pid
    end

    def stop
      Process.kill 'TERM', pid if running?
    end

    def static_file? path
      File.file? File.join(root, 'public', path)
    end

    def serve_static path
      File.read File.join(root, 'public', path)
    end

    def serve data
      UNIXSocket.open(sock) do |s|
        s.write data
        s.read
      end
    end

    def sock
      @sock ||= File.join(root, 'tmp/sockets/unicorn.sock')
    end

    def pid_file
      @pid_file ||= File.join(root, 'tmp/pids/unicorn.pid')
    end

    def pid
      File.read(pid_file).to_i if File.exists? pid_file
    end

  end
end
