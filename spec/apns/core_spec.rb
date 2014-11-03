require 'spec_helper'

describe APNS do
  before :each do
    @direct = double(APNS::DirectConnection)
    @proxy = double(APNS::ProxyConnection)
    allow(APNS::DirectConnection).to receive(:new).and_return(@direct)
    allow(APNS::ProxyConnection).to receive(:new).and_return(@proxy)
  end

  describe '.send_notifications' do
    it "writes to the connection" do
      expect(APNS).to receive(:open_connection).and_return(@direct)
      expect(@direct).to receive(:write)
      expect(@direct).to receive(:close)
      notification = APNS::Notification.new('token', {})
      APNS.send_notifications([notification])
    end
  end

  describe '.feedback' do
    it "reads from the connection" do
      expect(APNS).to receive(:feedback_connection).and_return(@direct)

      message = double("String")
      allow(message).to receive(:unpack).and_return(["ts", "size", "token"])
      time = Time.now
      allow(Time).to receive(:at).and_return(time)
      expect(@direct).to receive(:read).and_return(message)
      expect(@direct).to receive(:read).and_return nil
      expect(@direct).to receive(:close)
      expect(APNS.feedback).to eql([[time, "token"]])
    end
  end

  context "Connection methods" do
    before :each do
      @host = "gatewayhost"
      @feedback_host = 'feedbackhost'
      @port = 2195
      @feedback_port = 2196
      @pem = "Cert"
      @pass = "Passphrase"
      @proxy_host = "proxy"
      @proxy_port = 8080
      APNS.host = @host
      APNS.port = @port
      APNS.pem = @pem
      APNS.pass = @pass
    end

    [:open_connection, :feedback_connection].each do |connection_method|
      describe ".#{connection_method}" do
        before :each do
          if connection_method == :open_connection
            @connect_host =  @host
            @connect_port = @port
          else
            @connect_host = @feedback_host
            @connect_port = @feedback_port
          end
        end

        context "when proxy is specified" do
          before :each do
            APNS.proxy_host = @proxy_host
            APNS.proxy_port = @proxy_port
          end

          it "creates a connection" do
            expect(APNS).to receive(:create_connection).with([@proxy_host, @proxy_port, @connect_host, @connect_port, @pem, @pass])
            APNS.send(connection_method)
          end
        end
        
        context "when proxy is not specified" do
          before :each do
            APNS.proxy_host = nil
            APNS.proxy_port = nil
          end

          it "creates a connection" do
            expect(APNS).to receive(:create_connection).with([@connect_host, @connect_port, @pem, @pass])
            APNS.send(connection_method)
          end
        end
      end
    end

    describe ".create_connection" do
      it "creates a direct connection if proxy is not specified" do
        allow(APNS).to receive(:proxy?).and_return(false)
        expect(APNS::DirectConnection).to receive(:new).with("args")
        APNS.send(:create_connection, "args")
      end

      it "creates a proxy connection if proxy is not specified" do
        allow(APNS).to receive(:proxy?).and_return(true)
        expect(APNS::ProxyConnection).to receive(:new).with("args")
        APNS.send(:create_connection, "args")
      end
    end
  end

  describe ".feedback_host" do
    it "replaces gateway text in host with feedback" do
      APNS.host = "gatewayhost"
      expect(APNS.feedback_host).to eql("feedbackhost")
    end
  end

  describe ".feedback_port" do
    it "returns host port value incremented by 1" do
      APNS.port = 1111
      expect(APNS.feedback_port).to eql(1112)
    end
  end

  describe ".proxy?" do
    it "returns true if proxy is to be used" do
      APNS.proxy_host = "proxy_host"
      APNS.proxy_port = 8080
      expect(APNS.send(:proxy?)).to be_true
    end
    it "returns false if proxy shouldn't be used" do
      APNS.proxy_host = nil
      APNS.proxy_port = nil
      expect(APNS.send(:proxy?)).to be_false
    end
  end
end