require 'rake/testtask'

task :default do
  puts `rake -T`
end

desc 'Run unit and integration tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/test/{integration, unit}/**/*_spec.rb'
  t.warning = false
end

desc 'Run unit and integration tests'
Rake::TestTask.new(:spec_all) do |t|
  t.pattern = 'spec/tests/**/*_spec.rb'
  t.warning = false
end

desc 'Keep rerunning unit/integration tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
end

# NOTE: run `rake run:test` in another process
desc 'Run acceptance tests'
Rake::TestTask.new(:spec_accept) do |t|
  t.pattern = 'spec/tests/acceptance/*_spec.rb'
  t.warning = false
end

desc 'Keep restarting web app upon changes'
task :rerack do
  sh "rerun -c rackup -p 9292 --ignore 'coverage/*'"
end

namespace :run do
  task :dev do
    sh 'rerun -c "rackup -p 9292"'
  end
  task :test do
    sh 'RACK_ENV=test rackup -p 9000'
  end
end

desc 'Run application console'
task :console do
  sh 'pry -r ./init'
end

desc 'update spec/fixtures/nofb_results.yml'
task :update_yml do
  sh 'ruby lib/project_info.rb'
end

namespace :quality do
  only_app = 'config/ app/'

  desc 'run all quality checks'
  task all: %i[rubocop reek flog]

  task :rubocop do
    sh 'rubocop'
  end

  task :reek do
    sh 'reek'
  end

  task :flog do
    sh "flog -m #{only_app}"
  end
end

namespace :cache do
  task :config do
    require_relative 'config/environment.rb'
    require_relative 'app/infrastructure/cache/init.rb'
    @api = NoFB::Api
  end

  namespace :list do
    task :dev do
    end
    task :production => :config do
    end
  end
  
  namespace :wipe do
    task :dev do
    end
    task :production => :config do
    end
  end
end
