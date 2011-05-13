module Hoof
  class Application
    attr_accessor :root, :app, :name

    def initialize name
      @name = name
      @root = File.readlink(File.expand_path(File.join("~/.hoof/", name)))

      load_rvm
      start
    end

    def start
      system "cd #{root} && unicorn_rails -l #{sock} -E development -D"
    end

    def stop
      Process.kill "TERM", pid
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

    def static? path
      File.file? File.join(root, 'public', path)
    end

    def serve_static path
      File.read File.join(root, 'public', path)
    end

    def serve data
      s = UNIXSocket.open(sock)
      s.write data
      s.read
    end

    def sock
      @sock ||= "/tmp/hoof_#{name}.dev.sock"
    end

    def pid_file
      @pid_file ||= File.join(root, 'tmp/pids/unicorn.pid')
    end

    def pid
      File.read(pid_file).to_i
    end

  end
end
