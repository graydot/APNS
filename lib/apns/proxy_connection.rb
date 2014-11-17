require 'net/http'
require 'openssl'
require 'socket'
require 'apns/connection_methods'

module APNS
  class ProxyConnection
    include APNS::ConnectionMethods
    
    PROXY_READ_TIMEOUT = 60
    def initialize(proxy_host, proxy_port, host, port, pem, pass)
      raise "The path to your pem file is not set. (APNS.pem = /path/to/cert.pem)" unless pem
      raise "The path to your pem file does not exist!" unless File.exist?(pem)

      context      = OpenSSL::SSL::SSLContext.new
      context.cert = OpenSSL::X509::Certificate.new(File.read(pem))
      context.key  = OpenSSL::PKey::RSA.new(File.read(pem), pass)

      socket       = TCPSocket.new(proxy_host, proxy_port)  
      @ssl         = OpenSSL::SSL::SSLSocket.new(socket, context)
      @ssl.sync_close = true

      proxy_connect(host, port)
      @ssl.connect
    end

    private
    def proxy_connect(host, port)
      io = Net::BufferedIO.new(@ssl)
      io.read_timeout = PROXY_READ_TIMEOUT
      io.writeline sprintf("CONNECT %s:%s HTTP/%s", host, port, 1.0)
      io.writeline "Host: #{host}:#{port}"
      io.writeline "Proxy-Connection: Keep-Alive"
      io.writeline ""
      Net::HTTPResponse.read_new(io).value
    end
  end
end