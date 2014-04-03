module Rally
  class Task

    attr_accessor :start_time, :estimate

    def start
      self.start_time = Time.current
    end

  end
end
