# Coding: UTF-8
require 'net/http'
require 'uri'
require 'json'

# Net::HTTPResponseクラスにeach_lineメソッドを追加
module Net
  class HTTPResponse
    def each_line(rs = "\n")
      stream_check
      while line = @socket.readuntil(rs)
        yield line
      end
      self
    end
  end
end

module CSD
  class Client
    def initialize(url)
      @url = url
    end
    
    def stream
      uri = URI.parse(@url)
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        http.request(request) do |response|
          response.each_line("\r\n") do |line|
            status = JSON.parse(line, symbolize_names: true) rescue next
            yield(status)
          end
        end
      end
    end
  end
end

client = CSD::Client.new('http://csd.hoge.com/servers/stream')
client.stream do |object|
  p object
end