require File.expand_path '../../lib/bizo', __FILE__
require 'rubygems'
require 'fakeweb'
require 'shoulda'
require 'test/unit'


class Test::Unit::TestCase
  context "an api client" do
    setup do
      FakeWeb.allow_net_connect = false
      @client = Bizo::Client.new "key", "secret"
    end

    context "classify" do
      setup do
        request = send { @client.classify :email => "foo@bizo.com", :title => "hello!" }
        @path  = request.path
      end

      should "hit right path for classify" do
        assert @path.start_with? "/v1/classify.json?api_key=key"
      end

      should "contain hashed email" do
        assert @path.include?("&email=#{Digest::SHA1.hexdigest('foo@bizo.com')}")
      end

      should "contain title" do 
        assert @path.include?("&title=hello!")
      end

      should "contain oauth params" do 
        assert contains_oauth_params(@path) 
      end
    end

    context "profile" do
      setup do
        request = send { @client.profile }
        @path  = request.path
      end

      should "hit right path for profile" do
        assert @path.start_with?("/v1/profile.json?api_key=key")
      end

      should "contain oauth params" do
        assert contains_oauth_params(@path)
      end 
    end


    context "taxonomy" do
      setup do
        request = send { @client.taxonomy}
        @path  = request.path
      end

      should "hit right path for taxonomy" do
        assert @path.start_with?("/v1/taxonomy.json?api_key=key")
      end

      should "contain oauth params" do
        assert contains_oauth_params(@path)
      end
    end


    context "account" do
      setup do
        request = send { @client.account }
        @path  = request.path
      end

      should "hit right path for taxonomy" do
        assert @path.start_with?("/v1/account.json?api_key=key")
      end

      should "contain oauth params" do
        assert contains_oauth_params(@path)
      end
    end
  end


  private 

  def contains_oauth_params(path)
    path.include?("&oauth_consumer_key=key&oauth_signature_method=HMAC-SHA1")
  end

  def send
    begin 
      yield
    rescue FakeWeb::NetConnectNotAllowedError
      return FakeWeb.last_request
    end
  end
end
