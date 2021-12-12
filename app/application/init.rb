# frozen_string_literal: true

%w[controllers representers forms services].each do |folder|
  require_relative "#{folder}/init.rb"
end
