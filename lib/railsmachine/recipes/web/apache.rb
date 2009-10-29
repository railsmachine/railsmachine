require 'erb'
Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :apache do
  
    desc "Configure Apache. This uses the :use_sudo
    variable to determine whether to use sudo or not. By default, :use_sudo is
    set to true."
    task :configure, :roles => :web do      
      set_apache_conf
      conf_dir = File.dirname(apache_conf)

      # Try to make the conf directory, in case user has configured something
      # different, or conf/apps isn't present in the system image
      run("[ -d #{conf_dir} ] && echo \"yes\" || echo \"no\"") do |c, s, o|
        if o =~ /no?/
          puts "Directory #{conf_dir} not found, creating it..."
          send(run_method, "mkdir -p #{conf_dir}")
        end
      end
      
      run("[ -f #{ apache_conf} ] && echo \"yes\" || echo \"no\"") do |c, s, o|
        if o =~ /yes?/
          backup = "#{ apache_conf}.old.#{Time.now.strftime('%Y%m%d%H%M%S')}"
          send(run_method, "cp #{ apache_conf} #{backup}")
          exit if Capistrano::CLI.ui.ask("WARNING: You are about to change your existing Apache configuration. A backup has been created at #{backup}. Are you sure you want to proceed? [y/N]").upcase != "Y"
        end
      end
      
      server_aliases = []
      server_aliases << "www.#{ apache_server_name}"
      server_aliases.concat  apache_server_aliases
      set :apache_server_aliases_array, server_aliases
      
      file = File.join(File.dirname(__FILE__), "templates", app_server.to_s, "httpd.conf")
      template = File.read(file)
      buffer = ERB.new(template).result(binding)
      
      if  apache_ssl_enabled
        file = File.join(File.dirname(__FILE__), "templates", app_server.to_s, "httpd-ssl.conf")
        template = File.read(file)
        ssl_buffer = ERB.new(template).result(binding)
        buffer += ssl_buffer
      end
      
      put buffer, "#{shared_path}/httpd.conf", :mode => 0444
      send(run_method, "cp #{shared_path}/httpd.conf #{ apache_conf}")
      send(run_method, "rm -f #{shared_path}/httpd.conf")
    end
    
    desc "Start Apache "
    task :start, :roles => :web do
      send(run_method, "#{ apache_ctl} start")
    end
    
    desc "Restart Apache "
    task :restart, :roles => :web do
      send(run_method, "#{ apache_ctl} restart")
    end
    
    desc "Stop Apache "
    task :stop, :roles => :web do
      send(run_method, "#{ apache_ctl} stop")
    end
    
    desc "Reload Apache "
    task :reload, :roles => :web do
      send(run_method, "#{ apache_ctl} reload")
    end
  
  end
  
  def set_apache_conf
    if  apache_default_vhost
      set :apache_conf, "/etc/httpd/conf/default.conf" unless  apache_default_vhost_conf
    else
      set :apache_conf, "/etc/httpd/conf/apps/#{application}.conf" unless  apache_conf
    end
  end
  
end
