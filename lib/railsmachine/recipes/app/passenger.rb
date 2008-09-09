Capistrano::Configuration.instance(:must_exist).load do
  set :pasenger_environment, "production"
  set :passenger_user, nil
  set :passenger_group, nil
  set :use_mod_rewrite, false
 
  namespace :passenger do

    [:start, :stop].each do |t|
      desc "The :#{t} task no effect when using Passenger as your application server."
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

  namespace :deploy do
    
    desc <<-DESC
    This has no effect when using passenger.
    DESC
    task :start, :roles => :app do
      passenger.start
    end
  
    desc <<-DESC
    Restart passenger.
    DESC
    task :restart, :roles => :app do
      passenger.restart
    end
  
    desc <<-DESC
    This has no effect when using passenger.
    DESC
    task :stop, :roles => :app do
      passenger.stop
    end
  
  end
  
end
