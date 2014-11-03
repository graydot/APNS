module APNS
  class DirectConnection
    include APNS::ConnectionMethods
    def initialize(host, port, pem, pass)
      raise "The path to your pem file is not set. (APNS.pem = /path/to/cert.pem)" unless pem
      raise "The path to your pem file does not exist!" unless File.exist?(pem)

      context      = OpenSSL::SSL::SSLContext.new
      context.cert = OpenSSL::X509::Certificate.new(File.read(pem))
      context.key  = OpenSSL::PKey::RSA.new(File.read(pem), pass)

      socket      = TCPSocket.new(host, port)      
      @ssl         = OpenSSL::SSL::SSLSocket.new(socket, context)
      @ssl.sync_close = true
      @ssl.connect
    end
  end
end