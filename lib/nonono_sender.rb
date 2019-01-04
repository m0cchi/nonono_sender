require "nonono_sender/version"

module NononoSender
  class Error < StandardError; end
  class Starter
    def initialize(sender)
      @sender = sender
    end

    def start(recv)
      @t = Thread.new do
        @sender.accept do |event|
          recv.each do |r|
            max_count = @sender.retryable? ? @sender.retry_count : 0
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
      @t.run
    end

    def exit
      @t.kill
    end

    def alive?
      defined? @t && @t.alive?
    end
  end

  S = []
  def init; end
  def start(recv)
    raise Error if defined? @starter
    @starter = Starter.new(self)
    @starter.start(recv)
  end

  def exit
    raise Error unless defined? @starter
    @starter.exit
    remove_instance_variable(:@starter)
  end

  def alive?
    defined? @starter && @start.alive?
  end

  def retryable?
    false
  end

  def retry_count
    0
  end

  def accept(&block); end

end
