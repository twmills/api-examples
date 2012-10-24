require 'rubygems'
require 'bundler'
require 'pp'
require 'rubygems'
require 'httparty'
require 'json'
require 'hashie'

class PDClient
  attr_reader :client

  def initialize(subdomain, username, password)
    @client = Module.new do
      include HTTParty
      format :json
      base_uri "http://#{subdomain}.pagerduty.dev/api/v1"
      basic_auth username, password
    end
  end

  def http(method, urlpart, args = {})
    urlpart = URI.encode "/" + urlpart.to_s
    r = client.__send__ method.to_s, urlpart, :headers => {'Content-Type' => 'application/json'}, :body => args.to_json
    raise "Something really wrong happened" if r.code == 500
    ret = Hashie::Mash.new convert_data_to_object(r)
    error = ret.error || ret.errors
    if error
      warn error.inspect
      raise "Bad request"
    end
    ret
  end

  def convert_data_to_object(r)
    begin
      return do_convert_data_to_object(r)
    rescue Exception => e
      warn "ERROR: The body was #{r.body.inspect}"
      raise e
    end
  end

  def do_convert_data_to_object(r)
    return {} if r.body.nil?
    JSON.parse r.body
  end

  def get(urlpart)
    http :get, urlpart
  end

  def post(urlpart, args = {})
    http :post, urlpart, args
  end

  def delete(urlpart)
    http :delete, urlpart
  end

  def put(urlpart, args = {})
    http :put, urlpart, args
  end

  PAGINATION_SIZE = 100
  # The sugar on top
  def services
    ret = []
    offset = 0
    loop do
      cur = get("services?limit=#{PAGINATION_SIZE}&offset=#{offset}")
      offset += PAGINATION_SIZE
      ret.push *cur.services
      break if offset >= cur.total
    end
    ret
  end

  def create_maintenance_window(services, opts)
    opts[:service_ids] = services.map(&:id)
    post(:maintenance_windows, :maintenance_window => opts)
  end

end
