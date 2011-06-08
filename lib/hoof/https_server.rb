module Hoof
  class HttpsServer < HttpServer

    def post_init
      super
      start_tls
    end

  end
end
