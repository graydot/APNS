module APNS
  require 'socket'
  require 'openssl'
  require 'json'

  @host = 'gateway.sandbox.push.apple.com'
  @port = 2195
  # openssl pkcs12 -in mycert.p12 -out client-cert.pem -nodes -clcerts
  @pem = nil # this should be the path of the pem file not the contentes
  @pass = nil

  class << self
    attr_accessor :host, :pem, :pass, :port, :proxy_host, :proxy_port
  end

  def self.send_notification(device_token, message)
    n = APNS::Notification.new(device_token, message)
    self.send_notifications([n])
  end

  def self.send_notifications(notifications)
    connection = self.open_connection

    packed_nofications = self.packed_nofications(notifications)

    notifications.each do |n|
      connection.write(packed_nofications)
    end

    connection.close
  end

  def self.packed_nofications(notifications)
    bytes = ''

    notifications.each do |notification|
      # Each notification frame consists of
      # 1. (e.g. protocol version) 2 (unsigned char [1 byte]) 
      # 2. size of the full frame (unsigend int [4 byte], big endian)
      pn = notification.packaged_notification
      bytes << ([2, pn.bytesize].pack('CN') + pn)
    end

    bytes
  end

  def self.feedback
    connection = self.feedback_connection

    apns_feedback = []

    while message = connection.read(38)
      timestamp, token_size, token = message.unpack('N1n1H*')
      apns_feedback << [Time.at(timestamp), token]
    end

    connection.close

    return apns_feedback
  end

  protected

  def self.open_connection
    args = [@host, @port, @pem, @pass]
    if proxy?
      args.unshift(@proxy_host, @proxy_port)
    end
    return create_connection(args)
  end

  def self.feedback_connection
    args = [feedback_host, feedback_port, @pem, @pass]
    if proxy?
      args.unshift(@proxy_host, @proxy_port)
    end

    return create_connection(args)
  end

  def self.feedback_host
    @host.gsub('gateway','feedback')
  end

  def self.feedback_port
    @port + 1
  end

  def self.proxy?
    @proxy_host && @proxy_port
  end

  def self.create_connection(args)
    connection = if proxy?
      ProxyConnection.new(*args)
    else
      DirectConnection.new(*args)
    end
    connection
  end

  private_class_method :proxy?, :create_connection
end
