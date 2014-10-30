require File.dirname(__FILE__) + '/../spec_helper'

describe APNS::DirectConnection do
  before :each do
    @host = 'host'
    @port = 1111
    @pem = "pem file location"
    @pass = "passphrase"
    context = double('SSLContext')
    allow(OpenSSL::SSL::SSLContext).to receive(:new).and_return(context)
    allow(context).to receive(:cert=)
    allow(context).to receive(:key=)
    allow(File).to receive(:read).with(@pem).and_return('cert file')
    allow(File).to receive(:exist?).with(@pem).and_return(true)
    allow(OpenSSL::X509::Certificate).to receive(:new).with('cert file').and_return('cert')
    allow(OpenSSL::PKey::RSA).to receive(:new).with('cert file', @pass).and_return('key')
    socket = double('TCPSocket')
    allow(TCPSocket).to receive(:new).with(@host, @port).and_return(socket)
    @ssl = double('SSL Socket')
    allow(OpenSSL::SSL::SSLSocket).to receive(:new).with(socket, context).and_return(@ssl)
    allow(@ssl).to receive(:sync_close=).with(true)
    allow(@ssl).to receive(:connect)
  end

  it "raises an exception if pem file name isn't provided" do
    expect { APNS::DirectConnection.new(@host, @port, nil, @pass) }.to raise_error
  end

  it "raises an exception if pem file does not exist" do
    allow(File).to receive(:exist?).with(@pem).and_return(false)
    expect { APNS::DirectConnection.new(@host, @port, @pem, @pass) }.to raise_error
  end

  it "connects directly to apns servers" do
    expect(TCPSocket).to receive(:new).with(@host, @port)
    APNS::DirectConnection.new(@host, @port, @pem, @pass)
  end

  it "establishes an ssl connection" do
    expect(@ssl).to receive(:connect)
    APNS::DirectConnection.new(@host, @port, @pem, @pass)
  end

  describe '#write' do
    before :each do
      @connection = APNS::DirectConnection.new(@host, @port, @pem, @pass)
    end
    it "writes bytes to ssl socket" do
      bytes = "some bytes"
      expect(@ssl).to receive(:write).with(bytes)
      @connection.write(bytes)
    end
  end

  describe '#read' do
    before :each do
      @connection = APNS::DirectConnection.new(@host, @port, @pem, @pass)
    end
    it "reads bytes from ssl socket" do
      length = 200
      expect(@ssl).to receive(:read).with(length)
      @connection.read(length)
    end
  end

  describe '#close' do
    before :each do
      @connection = APNS::DirectConnection.new(@host, @port, @pem, @pass)
    end
    it "closes the ssl socket" do
      expect(@ssl).to receive(:close)
      @connection.close
    end
  end
end