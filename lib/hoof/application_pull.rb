module Hoof
  class ApplicationPull < Hash

    def add name
      self[name] ||= Hoof::Application.new name
    end

    def stop
      each do |(name, app)|
        app.stop
      end
    end

  end
end
