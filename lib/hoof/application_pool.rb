module Hoof
  class ApplicationPool < Hash

    def add name
      self[name] ||= Hoof::Application.new name
    end

    def list
      keys
    end

    def stop
      each do |(name, app)|
        app.stop
      end
    end

  end
end
