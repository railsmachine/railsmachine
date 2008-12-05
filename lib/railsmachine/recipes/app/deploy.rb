Capistrano::Configuration.instance(:must_exist).load do
  load    'config/deploy'
  namespace :deploy do
  
    desc <<-DESC
    #{app_server.to_s == 'mongrel' ? "Start the mongrel processes on the app server." : "This task no effect when using Passenger as your application server."}
    DESC
    task :start, :roles => :app do
      app_server.to_s == 'mongrel' ? mongrel.cluster.start : passenger.start
    end

    desc <<-DESC
    Restart the #{app_server} processes on the app server.
    DESC
    task :restart, :roles => :app do
      app_server.to_s == 'mongrel' ? mongrel.cluster.restart : passenger.restart
    end

    desc <<-DESC
    #{app_server.to_s == 'mongrel' ? "Stop the mongrel processes on the app server." : "This task no effect when using Passenger as your application server."} 
    DESC
    task :stop, :roles => :app do
      app_server.to_s == 'mongrel' ? mongrel.cluster.stop : passenger.stop
    end

  end

end