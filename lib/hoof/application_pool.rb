module Hoof
  class ApplicationPool < Hash

    def reload
      Dir[File.expand_path('~/.hoof/*')].each do |dir|
        name = File.basename dir
        self[name] = Hoof::Application.new name if File.symlink? dir
      end
    end

    def stop
      each do |(name, app)|
        app.stop
      end
    end

  end
end
