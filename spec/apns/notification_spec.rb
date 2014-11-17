require 'spec_helper'

describe APNS::Notification do
  
  it "should take a string as the message" do
    n = APNS::Notification.new('device_token', 'Hello')
    n.alert.should == 'Hello'
  end
  
  it "should take a hash as the message" do
    n = APNS::Notification.new('device_token', {:alert => 'Hello iPhone', :badge => 3})
    n.alert.should == "Hello iPhone"
    n.badge.should == 3
  end
  
  it "should have a priority if content_availible is set"  do
    n = APNS::Notification.new('device_token', {:content_available => true})
    n.content_available.should be_true
    n.priority.should eql(5)
  end

  describe '#packaged_message' do
    
    it "should return JSON with notification information" do
      n = APNS::Notification.new('device_token', {
        :alert => 'Hello iPhone', 
        :badge => 3, 
        :sound => 'awesome.caf'
      })
      expect(JSON.parse(n.packaged_message)).to eql({
        "aps" => {
          "alert" => "Hello iPhone",
          "badge" => 3,
          "sound" => "awesome.caf"
        }
      })
    end

    it "should support the iOS 8 category key" do
      n = APNS::Notification.new('device_token', {
        :alert => 'Hello iPhone', 
        :badge => 3, 
        :category => 'CATEGORY_IDENTIFIER'
      })
      expect(JSON.parse(n.packaged_message)).to eql({
        "aps" => {
          "alert" => "Hello iPhone",
          "badge" => 3, 
          "category" => 'CATEGORY_IDENTIFIER'
        }
      })
    end

    it "should not include keys that are empty in the JSON" do
      n = APNS::Notification.new('device_token', {:badge => 3})
      expect(JSON.parse(n.packaged_message)).to eql({
        "aps" => {
          "badge" => 3
        }
      })
    end

    it "should return JSON with content availible" do
      n = APNS::Notification.new('device_token', {:content_available => true})
      expect(JSON.parse(n.packaged_message)).to eql({
        "aps" => {
          "content-available" => 1
        }
      })
    end
    
  end
  
  describe '#package_token' do
    it "should package the token" do
      n = APNS::Notification.new('<5b51030d d5bad758 fbad5004 bad35c31 e4e0f550 f77f20d4 f737bf8d 3d5524c6>', 'a')
      Base64.encode64(n.packaged_token).should == "W1EDDdW611j7rVAEutNcMeTg9VD3fyDU9ze/jT1VJMY=\n"
    end
  end

  describe '#packaged_notification' do
    it "should package the token" do
      n = APNS::Notification.new('device_token', {
        :alert => 'Hello iPhone', 
        :badge => 3, 
        :message_identifier => 'random',
        :sound => 'awesome.caf'
      })
      allow(n).to receive(:packaged_message).and_return('{"packaged": "message"}') #actual message json has ordering depending on ruby version
      expect(Base64.encode64(n.packaged_notification)).to eql("AQAG3vLO/YTnAgAXeyJwYWNrYWdlZCI6ICJtZXNzYWdlIn0DAAZyYW5kb20E\nAAQAAAAABQABCg==\n")
    end
  end
  
end
