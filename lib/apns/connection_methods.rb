module APNS
  module ConnectionMethods
    def write(bytes)
      @ssl.write(bytes)
    end

    def read(length)
      @ssl.read(length)
    end

    def close
      @ssl.close
    end
  end
end