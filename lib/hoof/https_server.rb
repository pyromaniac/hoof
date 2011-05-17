module Hoof
  class HttpsServer < HttpServer

    def post_init
      start_tls
    end

  end
end
