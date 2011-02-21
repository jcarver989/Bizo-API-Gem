require 'oauth'
require 'oauth/consumer'
require 'json'

module Bizo
  class Base
    def initialize(key, secret)
      @key = key
      @secret = secret
      @consumer = OAuth::Consumer.new(@key, @secret, {
        :site        => API_URL,
        :scheme      => :query_string,
        :http_method => :get
      })
    end

  protected
    def request(method, path, raw_params = {})
      path_with_key = "#{path}?api_key=#{@key}"
      url  = raw_params.inject(path_with_key) { |path,(k,v)| path + "&#{k}=#{v}" }
      full_path = URI.escape(url)
      JSON.parse @consumer.request(method,full_path).body
    end
  end
end
