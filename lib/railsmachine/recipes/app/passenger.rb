Capistrano::Configuration.instance(:must_exist).load do
  set :use_mod_rewrite, false
  load    'config/deploy'
  namespace :passenger do

    [:start, :stop].each do |t|
      task t, :roles => :app do
        puts "The :#{t} task no effect when using Passenger as your application server."
      end
    end

    desc <<-DESC
    Restart the Passenger processes on the app server by touching tmp/restart.txt.
    DESC
    task :restart, :roles => :app do
      run "touch #{current_path}/tmp/restart.txt"
    end

  end
end
