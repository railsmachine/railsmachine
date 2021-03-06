Capistrano::Configuration.instance(:must_exist).load do
 
  namespace :mongrel do
  
    namespace :cluster do
    
      desc <<-DESC
      Configure Mongrel processes on the app server. This uses the :use_sudo
      variable to determine whether to use sudo or not. By default, :use_sudo is
      set to true.
      DESC
      task :configure, :roles => :app do
        set_mongrel_conf
        set_mongrel_pid_file
            
        argv = []
        argv << "#{mongrel_rails} cluster::configure"
        argv << "-N #{mongrel_servers.to_s}"
        argv << "-p #{mongrel_port.to_s}"
        argv << "-e #{mongrel_environment}"
        argv << "-a #{mongrel_address}"
        argv << "-c #{current_path}"
        argv << "-C #{mongrel_conf}"
        argv << "-P #{mongrel_pid_file}"
        argv << "-l #{mongrel_log_file}" if mongrel_log_file
        argv << "--user #{mongrel_user}" if mongrel_user
        argv << "--group #{mongrel_group}" if mongrel_group
        argv << "--prefix #{mongrel_prefix}" if mongrel_prefix
        argv << "-S #{mongrel_config_script}" if mongrel_config_script
        cmd = argv.join " "
        send(run_method, cmd)
      end
      
      desc <<-DESC
      Start Mongrel processes on the app server.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is
      set to true.
      DESC
      task :start, :roles => :app do
        set_mongrel_conf
        cmd = "#{mongrel_rails} cluster::start -C #{mongrel_conf}"
        cmd += " --clean" if mongrel_clean    
        send(run_method, cmd)
      end
      
      desc <<-DESC
      Restart the Mongrel processes on the app server by starting and stopping the cluster. This uses the :use_sudo
      variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
      DESC
      task :restart, :roles => :app do
        set_mongrel_conf
        cmd = "#{mongrel_rails} cluster::restart -C #{mongrel_conf}"
        cmd += " --clean" if mongrel_clean    
        send(run_method, cmd)
      end
      
      desc <<-DESC
      Stop the Mongrel processes on the app server.  This uses the :use_sudo
      variable to determine whether to use sudo or not. By default, :use_sudo is
      set to true.
      DESC
      task :stop, :roles => :app do
        set_mongrel_conf
        cmd = "#{mongrel_rails} cluster::stop -C #{mongrel_conf}"
        cmd += " --clean" if mongrel_clean    
        send(run_method, cmd)
      end

      desc <<-DESC
      Check the status of the Mongrel processes on the app server.  This uses the :use_sudo
      variable to determine whether to use sudo or not. By default, :use_sudo is
      set to true.
      DESC
      task :status, :roles => :app do
        set_mongrel_conf
        send(run_method, "#{mongrel_rails} cluster::status -C #{mongrel_conf}")
      end
      
      desc <<-DESC
      Remove the mongrel cluster configuration from the app server.
      DESC
      task :remove, :roles => :app do 
        set_mongrel_conf
        alt_mongrel_conf = mongrel_conf.gsub('.conf','.yml')
        run("[ -f #{mongrel_conf} ] || [ -f #{alt_mongrel_conf} ] && echo \"yes\" || echo \"no\"") do |c, s, o|
          if o =~ /yes?/
            exit if Capistrano::CLI.ui.ask("WARNING: You are about to remove your mongrel cluster configuration. Are you sure you want to proceed? [y/N]").upcase != "Y"
            mongrel.cluster.stop
            sudo("rm -f #{mongrel_conf}")
            sudo("rm -f #{alt_mongrel_conf}")
          end
        end
      end
  
    end
    
  end
  
  def set_mongrel_conf
    set :mongrel_conf, "/etc/mongrel_cluster/#{application}.conf" unless mongrel_conf
  end

  def set_mongrel_pid_file
    set :mongrel_pid_file, "/var/run/mongrel_cluster/#{application}.pid" unless mongrel_pid_file
  end
end
