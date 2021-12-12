# frozen_string_literal: true

%w[infrastructure application presentation].each do |folder|
  require_relative "#{folder}/init.rb"
end
