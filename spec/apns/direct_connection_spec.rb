require 'spec_helper'

describe APNS::DirectConnection do
  before :each do
    @host = 'host'
    @port = 1111
    @pem = "pem file location"
    @pass = "passphrase"
    context = double('SSLContext', :cert= => nil, :key= => nil)
    allow(OpenSSL::SSL::SSLContext).to receive(:new).and_return(context)
    allow(File).to receive(:read).with(@pem).and_return('cert file')
    allow(File).to receive(:exist?).with(@pem).and_return(true)
    allow(OpenSSL::X509::Certificate).to receive(:new).with('cert file').and_return('cert')
    allow(OpenSSL::PKey::RSA).to receive(:new).with('cert file', @pass).and_return('key')
    socket = double('TCPSocket')
    allow(TCPSocket).to receive(:new).with(@host, @port).and_return(socket)
    @ssl = double('SSL Socket', :sync_close= => true, :connect => nil)
    allow(OpenSSL::SSL::SSLSocket).to receive(:new).with(socket, context).and_return(@ssl)
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

  subject(:connection) { APNS::DirectConnection.new(@host, @port, @pem, @pass) }

  it_behaves_like "a connection object"
end