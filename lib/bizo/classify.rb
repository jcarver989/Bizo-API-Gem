require 'rubygems'
require 'digest/sha1'
require 'json'
module Bizo
  module Classify < Base 
    def initialize(key,secret)
      super(key,secret)
    end

    def self.classify(params = {})
     email = params[:email]
     params[:email] = Digest::SHA1.hexdigest(email.downcase) unless email.nil? 
     request :get, CLASSIFY_PATH, params
    end

    private
    CLASSIFY_PATH = "/v1/classify.json"
  end
end
