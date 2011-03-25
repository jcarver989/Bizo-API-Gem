require File.expand_path '../../lib/bizo', __FILE__
require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)
require 'fakeweb'
require 'shoulda'
require 'mocha'
require 'test/unit'


class ClientTest < Test::Unit::TestCase
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

      context "a taxonomy" do
        setup do
          @taxonomy = {
            "taxonomy" => {
              "bizographics" => {
                "industry" => [
                  { "name" => "foo", "code" => "foo", "parent_code" => "foo_daddy" },
                  { "name" => "foo2", "code" => "foo2", "parent_code" => "foo_daddy2" },
                  { "name" => "foo3", "code" => "foo3" }
                ],

                "company_size" => [
                  { "name" => "large", "code" => "large" }
                ]
              }
            }
          }
          @client.stubs(:request).returns(@taxonomy)
        end 

        should "exclude unwanted categories" do
          result = @client.taxonomy :exclude => [:industry]
          assert_equal result, { "company_size" => [{"name" => "large", "code" => "large" }]}
        end

        should "exclude all unwanted categories" do
          result = @client.taxonomy :exclude => [:industry, :company_size]
          assert_equal result, {}
        end

        should "filter only top level" do
          result = @client.taxonomy :top_level => true
          assert_equal(result, {
            "industry" => [{ "name" => "foo3", "code" => "foo3" }],
            "company_size" => [{ "name" => "large", "code" => "large" }]
          })
        end

        should "filter top level and unwanted categories" do 
          result = @client.taxonomy :top_level => true, :exclude => [:company_size]
          assert_equal result, { "industry" => [{"name" => "foo3", "code" => "foo3"}]}
        end

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
    path.include?("&oauth_consumer_key=key") && path.include?("&oauth_signature_method=HMAC-SHA1")
  end

  def send
    begin 
      yield
    rescue FakeWeb::NetConnectNotAllowedError
      return FakeWeb.last_request
    end
  end
end
