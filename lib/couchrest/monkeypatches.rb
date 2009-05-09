# This file must be loaded after the JSON gem and any other library that beats up the Time class.
class Time
  # This date format sorts lexicographically
  # and is compatible with Javascript's <tt>new Date(time_string)</tt> constructor.
  # Note this this format stores all dates in UTC so that collation 
  # order is preserved. (There's no longer a need to set <tt>ENV['TZ'] = 'UTC'</tt>
  # in your application.)

  def to_json(options = nil)
    u = self.getutc
    %("#{u.strftime("%Y/%m/%d %H:%M:%S +0000")}")
  end

  # Decodes the JSON time format to a UTC time.
  # Based on Time.parse from ActiveSupport. ActiveSupport's version
  # is more complete, returning a time in your current timezone, 
  # rather than keeping the time in UTC. YMMV.
  # def self.parse string, fallback=nil
  #   d = DateTime.parse(string).new_offset
  #   self.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
  # rescue
  #   fallback
  # end
end

# Monkey patch for faster net/http io
if RUBY_VERSION.to_f < 1.9
  class Net::BufferedIO #:nodoc:
    alias :old_rbuf_fill :rbuf_fill
    def rbuf_fill
      if @io.respond_to?(:read_nonblock)
        begin
          @rbuf << @io.read_nonblock(65536)
        rescue Errno::EWOULDBLOCK
          if IO.select([@io], nil, nil, @read_timeout)
            retry
          else
            raise Timeout::TimeoutError
          end
        end
      else
        timeout(@read_timeout) do
          @rbuf << @io.sysread(65536)
        end
      end
    end
  end
end

module RestClient
  def self.copy(url, headers={})
    Request.execute(:method => :copy,
      :url => url,
      :headers => headers)
  end
end