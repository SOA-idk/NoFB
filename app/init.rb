# frozen_string_literal: true

%w[domain controllers].each do |folder|
  require_relative "#{folder}/init.rb"
end
