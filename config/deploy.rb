require 'shellwords'

require 'mina/git'
require 'mina/deploy'

set :codename, 'buckler'

set :term_mode, :pretty

set :user, 'deploy'
set :domain, ENV['DEPLOY_TARGET']
set :deploy_to, '/home/deploy/buckler_bot'
set :repository, 'git@github.com:BucklerBot/buckler.git'
set :branch, 'master'
set :shared_dirs, %w[elixir_logs]
set :forward_agent, true
set :execution_mode, :system
set :ssh_options, '-o StrictHostKeyChecking=no -o ForwardAgent=yes'

task setup: :environment do
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/elixir_logs")
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/deps")
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/_build")
  command %(mix local.hex --force)
  command %(mix local.rebar --force)
end

desc 'Deploys production'
task :production do
  command %(export MIX_ENV=prod)
end

task deploy: :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    command %(MIX_ENV=prod mix release.update)
    on :launch do
      in_path(fetch(:current_path)) do
        command %(cp ./buckler_bot.eye /home/deploy/)
        command %(sudo service eye restart)
        command %(sudo eye restart buckler_bot)
      end
    end
  end
end
