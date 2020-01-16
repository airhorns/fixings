# frozen_string_literal: true
require "fixings/version"

module Fixings
end

require "fixings/railtie" if defined?(Rails)
