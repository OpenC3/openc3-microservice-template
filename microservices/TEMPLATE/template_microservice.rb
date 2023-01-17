# encoding: ascii-8bit

# Copyright 2023 OpenC3, Inc.
# All Rights Reserved.
#
# This file may also be used under the terms of a commercial license
# if purchased from OpenC3, Inc.

require 'openc3/microservices/microservice'
require 'openc3/api/api'

module OpenC3
  class TemplateMicroservice < Microservice
    include Api # Provides access to api methods

    def initialize(name)
      super(name)
      @config['options'].each do |option|
        # Update with your own OPTION handling
        case option[0].upcase
        when 'PERIOD'
          @period = option[1].to_i
        else
          @logger.error("Unknown option passed to microservice #{@name}: #{option}")
        end
      end

      @period = 60 unless @period # 1 minutes
      @sleeper = Sleeper.new
    end

    def run
      while true
        start_time = Time.now
        break if @cancel_thread

        # Do your microservice work here
        Logger.info("Template Microservice ran")
        # cmd("INST ABORT")

        run_time = Time.now - start_time
        delta = @period - run_time
        if delta > 0
          # Delay till the next period
          break if @sleeper.sleep(delta) # returns true and breaks loop on shutdown
        end
      end
    end

    def shutdown
      @sleeper.cancel # Breaks out of run()
      super()
    end
  end
end

OpenC3::TemplateMicroservice.run if __FILE__ == $0
