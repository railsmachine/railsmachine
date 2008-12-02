require 'erb'
Capistrano::Configuration.instance(:must_exist).load do
  
  
  set :httpd_server_name, nil            
  set :httpd_conf, nil
  set :httpd_default_vhost, false
  set :httpd_default_vhost_conf, nil
  set :httpd_ctl, "/etc/init.d/httpd"
  set :httpd_server_aliases, []
  set :httpd_proxy_port, 8000
  set :httpd_proxy_servers, 2
  set :httpd_proxy_address, "127.0.0.1"
  set :httpd_ssl_enabled, false
  set :httpd_ssl_ip, nil
  set :httpd_ssl_forward_all, false
  
  load    'config/deploy'
  
  namespace :apache do
  
    desc "Configure Apache. This uses the :use_sudo
    variable to determine whether to use sudo or not. By default, :use_sudo is
    set to true."
    task :configure, :roles => :web do      
      set_httpd_conf
      
      run("[ -f #{httpd_conf} ] && echo \"yes\" || echo \"no\"") do |c, s, o|
        if o =~ /yes?/
          backup = "#{httpd_conf}.old.#{Time.now.strftime('%Y%m%d%H%M%S')}"
          send(run_method, "cp #{httpd_conf} #{backup}")
          exit if Capistrano::CLI.ui.ask("WARNING: You are about to change your existing Apache configuration. A backup has been created at #{backup}. Are you sure you want to proceed? [y/N]").upcase != "Y"
        end
      end
      
      server_aliases = []
      server_aliases << "www.#{httpd_server_name}"
      server_aliases.concat httpd_server_aliases
      set :httpd_server_aliases_array, server_aliases
      
      file = File.join(File.dirname(__FILE__), "templates", app_server.to_s, "httpd.conf")
      template = File.read(file)
      buffer = ERB.new(template).result(binding)
      
      if httpd_ssl_enabled
        file = File.join(File.dirname(__FILE__), "templates", app_server.to_s, "httpd-ssl.conf")
        template = File.read(file)
        ssl_buffer = ERB.new(template).result(binding)
        buffer += ssl_buffer
      end
      
      put buffer, "#{shared_path}/httpd.conf", :mode => 0444
      send(run_method, "cp #{shared_path}/httpd.conf #{httpd_conf}")
      send(run_method, "rm -f #{shared_path}/httpd.conf")
    end
    
    desc "Start Apache "
    task :start, :roles => :web do
      send(run_method, "#{httpd_ctl} start")
    end
    
    desc "Restart Apache "
    task :restart, :roles => :web do
      send(run_method, "#{httpd_ctl} restart")
    end
    
    desc "Stop Apache "
    task :stop, :roles => :web do
      send(run_method, "#{httpd_ctl} stop")
    end
    
    desc "Reload Apache "
    task :reload, :roles => :web do
      send(run_method, "#{httpd_ctl} reload")
    end
  
  end
  
  def set_httpd_conf
    if httpd_default_vhost
      set :httpd_conf, "/etc/httpd/conf/default.conf" unless httpd_default_vhost_conf
    else 
      set :httpd_conf, "/etc/httpd/conf/apps/#{application}.conf" unless httpd_conf
    end
  end
  
end
