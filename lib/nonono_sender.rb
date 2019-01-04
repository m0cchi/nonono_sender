require "nonono_sender/version"

module NononoSender
  class Error < StandardError; end

  S = []
  def init; end
  def start(recv)
    raise Error if defined? @t
    @recv = recv
    @t = Thread.new do
      run
    end
    @t.run
  end

  def run; end

  def exit
    raise Error unless defined? @starter
    @t.kill
    remove_instance_variable(:@starter)
  end

  def alive?
    defined? @t && @t.alive?
  end

  def retryable?
    false
  end

  def retry_count
    0
  end

  def send(event)
    @recv.each do |r|
      max_count = retryable? ? retry_count : 0
      count = 0
      begin
        count += 1
        r.recieve(event)
      rescue StandardError => e
        puts e
        if max_count > count
          sleep 3
          retry
        end
      end
    end
  end

end
