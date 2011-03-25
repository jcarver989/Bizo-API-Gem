require 'digest/sha1'

module Bizo
  class Client < Base
    def initialize(key,secret)
      super(key,secret)
    end

    def classify(params = {})
      email = params[:email]
      params[:email] = Digest::SHA1.hexdigest(email.downcase) unless email.nil? 
      request :get, CLASSIFY_PATH, params
    end

    def profile
      request :get, PROFILE_PATH
    end

    def account
      request :get, ACCOUNT_PATH
    end

    def taxonomy(opts = {})
      taxonomy     = request :get, TAXONOMY_PATH
      bizographics = taxonomy["taxonomy"]["bizographics"]
      bizographics.select! { |key, value| opts[:exclude].include?(key.to_sym) } unless opts[:exclude].nil? || opts[:exclude].empty?
      return bizographics unless opts[:top_level] == true

      bizographics.inject({}) do |filtered, pair|
        category, segments = pair 

        segments.each do |segment|
          filtered[key] ||= []
          filtered[key] << segment if segment["parent_code"].nil?
        end

        filtered
      end
    end

  
    private
    TAXONOMY_PATH = "/v1/taxonomy.json"
    ACCOUNT_PATH  = "/v1/account.json"
    PROFILE_PATH  = "/v1/profile.json"
    CLASSIFY_PATH = "/v1/classify.json"
  end
end
