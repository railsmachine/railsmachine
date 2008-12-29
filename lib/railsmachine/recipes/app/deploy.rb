Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
  
    desc <<-DESC
    Start the application server processes.
    DESC
    task :start, :roles => :app do
      application_servlet.start
    end

    desc <<-DESC
    Restart the application server processes.
    DESC
    task :restart, :roles => :app do
      application_servlet.restart
    end

    desc <<-DESC
    Stop the application server processes. 
    DESC
    task :stop, :roles => :app do
      application_servlet.stop
    end

  end

end