require 'bundler/capistrano'

set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
require 'new_relic/recipes'

set :application, "usasearch"
set :scm,         "git"
set :repository,  "git@github.com:GSA/#{application}.git"
set :use_sudo,    false
set :deploy_via, :remote_cache

before "deploy:restart", "deploy:maybe_migrate"
after 'deploy:finalize_update', 'deploy:copy_system_yml_to_config'
before 'deploy:create_symlink', 'deploy:web:disable'
before 'deploy:create_symlink', 'deploy:symlink_cache'
before 'deploy:create_symlink', 'deploy:create_js_symlink'
after 'deploy:restart', 'deploy:web:enable'
after 'deploy:restart', 'deploy:cleanup'
before "deploy:cleanup", "deploy:restart_rake_tasks"
after "deploy:update", "newrelic:notice_deployment"

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Only migrate if 'migrate' param is passed in via '-S migrate=true'"
  task :maybe_migrate, :roles => :db, :only => {:primary => true} do
    find_and_execute_task("deploy:migrate") if exists?(:migrate)
  end

  desc "Copy yaml files from shared_path/system to release_path/config"
  task :copy_system_yml_to_config, roles: :app do
    fetch(:system_yml_filenames).each do |name_without_ext|
      run "cp #{shared_path}/system/#{name_without_ext}.yml #{release_path}/config/#{name_without_ext}.yml"
    end
  end

  desc "Create symlink for tmp/cache"
  task :symlink_cache, :roles => :app do
    run "ln -s #{shared_path}/api_cache #{release_path}/tmp/api_cache"
  end

  desc 'Restart daemon rake tasks'
  task :restart_rake_tasks, :roles => :daemon do
    run "/home/search/scripts/stop_rake_tasks"
    run "/home/search/scripts/start_rake_tasks"
  end

  desc 'Create symlink for static resources'
  task :create_js_symlink, :roles => :web do
    run "ln -s #{shared_path}/assets/sayt_loader.js #{release_path}/public/javascripts/remote.loader.js"
    run "ln -s #{shared_path}/assets/stats.js #{release_path}/public/javascripts/stats.js"
    run "ln -s #{shared_path}/assets/sayt_loader.js #{release_path}/public/javascripts/sayt/remote.js"
  end
end

require './config/boot'
require 'airbrake/capistrano'
