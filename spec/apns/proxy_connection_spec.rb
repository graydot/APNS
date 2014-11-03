require 'spec_helper'

describe APNS::ProxyConnection do
  before :each do
    @host = 'host'
    @port = 1111
    @pem = "pem file location"
    @pass = "passphrase"
    @proxy_host = "proxy"
    @proxy_port = 8080
    context = double('SSLContext', :cert= => nil, :key= => nil)
    allow(OpenSSL::SSL::SSLContext).to receive(:new).and_return(context)
    allow(File).to receive(:read).with(@pem).and_return('cert file')
    allow(File).to receive(:exist?).with(@pem).and_return(true)
    allow(OpenSSL::X509::Certificate).to receive(:new).with('cert file').and_return('cert')
    allow(OpenSSL::PKey::RSA).to receive(:new).with('cert file', @pass).and_return('key')
    socket = double('TCPSocket')
    allow(TCPSocket).to receive(:new).with(@proxy_host, @proxy_port).and_return(socket)
    @ssl = double('SSL Socket', :sync_close= => true, :connect => nil)
    allow(OpenSSL::SSL::SSLSocket).to receive(:new).with(socket, context).and_return(@ssl)
    @io = double("Buffered IO", :writeline => nil)
    allow(Net::BufferedIO).to receive(:new).and_return(@io)
    allow(@io).to receive(:read_timeout=).with(APNS::ProxyConnection::PROXY_READ_TIMEOUT)
    response = double("Response", :value => nil)
    allow(Net::HTTPResponse).to receive(:read_new).with(@io).and_return(response)
  end

  it "raises an exception if pem file name isn't provided" do
    expect { APNS::ProxyConnection.new(@proxy_host, @proxy_port, @host, @port, nil, @pass) }.to raise_error
  end

  it "raises an exception if pem file does not exist" do
    allow(File).to receive(:exist?).with(@pem).and_return(false)
    expect { APNS::ProxyConnection.new(@proxy_host, @proxy_port, @host, @port, @pem, @pass) }.to raise_error
  end

  it "connects to proxy server via tcp socket" do
    expect(TCPSocket).to receive(:new).with(@proxy_host, @proxy_port)
    APNS::ProxyConnection.new(@proxy_host, @proxy_port, @host, @port, @pem, @pass)
  end

  it "establishes an ssl connection" do
    expect(@ssl).to receive(:connect)
    APNS::ProxyConnection.new(@proxy_host, @proxy_port, @host, @port, @pem, @pass)
  end

  subject(:connection) { APNS::ProxyConnection.new(@proxy_host, @proxy_port, @host, @port, @pem, @pass) }

  it_behaves_like "a connection object"

  describe '#proxy_connect' do
    it "sends connect to gateway over proxy to the proxy server" do
      connect_regex = /\ACONNECT #{@host}:#{@port}/
      host_regex = /\AHost: #{@host}:#{@port}/
      persistent_connection = "Proxy-Connection: Keep-Alive"
      expect(@io).to receive(:writeline).with(connect_regex)
      expect(@io).to receive(:writeline).with(host_regex)
      expect(@io).to receive(:writeline).with(persistent_connection)
      @connection = APNS::ProxyConnection.new(@proxy_host, @proxy_port, @host, @port, @pem, @pass)
    end
  end
end