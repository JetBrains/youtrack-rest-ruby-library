require "uri"
require "net/http"
require "cgi"

class Connection

  attr_reader :rest_path

  def initialize(yt_base_url)
    correct_uri = yt_base_url.gsub(/\/$/, '')
    uri = URI.parse(correct_uri)
    @rest_path = uri.path + "/rest"
    @connection = Net::HTTP.new(uri.host, uri.port)
    @headers = {}
  end

  def login(login, password)
    resp = request(:post, "#{@rest_path}/user/login", {'login' => login,
                                                  'password' => password})
    @headers = {"Cookie" => resp["set-cookie"], "Cache-Control" => "no-cache"}
  end

  def request(method_name, url, params = {}, body = nil)
    path = url
    unless params.empty?
      path = "#{url}?#{url_encode(params)}"
    end
    req = nil
    case method_name
      when :get
        req = Net::HTTP::Get.new(path, @headers)
      when :post
        req = Net::HTTP::Post.new(path, @headers)
      else
        #TODO handle this
    end
    @connection.start do |http|
      resp = http.request(req)
      resp.value
      resp
    end
  end

  private

  def url_encode(params)
    params.map{|key, value|"#{key}=#{value}"}.join("&")
  end

end