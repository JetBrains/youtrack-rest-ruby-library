require "uri"
require "net/http"

class YouTrackConnection
  def initialize(yt_base_url)
    correct_uri = yt_base_url.gsub(/\/$/, '')
    uri = URI.parse(correct_uri)
    @rest_path = uri.path + "/rest"
    @connection = Net::HTTP.new(uri.host, uri.port)
  end

  def login(login, password)
    @connection.start do |http|
      resp = request(:post, "#{@rest_path}/user/login", {'login' => login,
                                                    'password' => password})
      resp.value
      @headers = {"Cookie" => resp["seq_cookie"], "Cache-Control" => "no-cache"}
    end
  end

  def request(method_name, url, params = {}, body = nil)

  end

  private

  def url_encode(params)
    params.map{|key, value|"#{key}=#{value}"}.join("&")
  end

end