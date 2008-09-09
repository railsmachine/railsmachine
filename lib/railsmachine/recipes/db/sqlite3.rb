require 'capistrano'
require 'capistrano/cli'

Capistrano::Configuration.instance(:must_exist).load do

  namespace :db do

    desc "Do nothing when using sqlite3."
    task :setup, :roles => :db, :only => { :primary => true } do
    end

  end

end
