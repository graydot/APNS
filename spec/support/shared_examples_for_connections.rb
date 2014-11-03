RSpec.shared_examples "a connection object" do
  describe '#write' do
    it "writes bytes to ssl socket" do
      bytes = "some bytes"
      expect(@ssl).to receive(:write).with(bytes)
      connection.write(bytes)
    end
  end

  describe '#read' do
    it "reads bytes from ssl socket" do
      length = 200
      expect(@ssl).to receive(:read).with(length)
      connection.read(length)
    end
  end

  describe '#close' do
    it "closes the ssl socket" do
      expect(@ssl).to receive(:close)
      connection.close
    end
  end
end