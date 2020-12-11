require "faraday"

module Uploadcare
  module Connections
    class UploadConnection < Faraday::Connection
      def initialize options
        ca_path = '/etc/ssl/certs' if File.exists?('/etc/ssl/certs')

        super ssl: { ca_path: ca_path }, url: options[:upload_url_base] do |frd|
          frd.request :multipart
          frd.request :url_encoded
          frd.headers['User-Agent'] = UserAgent.new.call(options)

          frd.response :uploadcare_raise_error
          frd.response :uploadcare_parse_json

          Array(options[:upload_middlewares]).each { |middleware| frd.use(middleware) }

          frd.adapter :net_http
        end
      end
    end
  end
end
