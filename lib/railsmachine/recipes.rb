Capistrano::Configuration.instance(:must_exist).load do

  default_run_options[:pty] = true
  set :keep_releases, 3
  set :app_symlinks, nil

  set :scm, :subversion
  set :valid_scms, [:subversion, :git]

  set :httpd, :apache
  set :valid_httpds, [:apache, :nginx]

  set :app_server, :mongrel
  set :valid_app_servers, [:mongrel, :passenger]

  set :db_adapter, :mysql
  set :valid_db_adapters, [:mysql, :postgresql, :sqlite3]

  set :rails_env, "production"

  set :repository do
    scm = fetch(:scm)
    repos_base = "#{user}@#{domain}#{deploy_to}"
    if scm == :subversion
      "svn+ssh://#{repos_base}/repos/trunk"
    elsif scm == :git
      "ssh://#{repos_base}/#{application}.git"
    end
  end

  
  task :validate_required_variables do
    raise ArgumentError, invalid_variable_value(scm, "scm", valid_scms) unless valid?(scm, valid_scms)
    raise ArgumentError, invalid_variable_value(app_server, "app_server", valid_app_servers) unless valid?(app_server, valid_app_servers)
    raise ArgumentError, invalid_variable_value(httpd, "httpd", valid_httpds) unless valid?(httpd, valid_httpds)
    raise ArgumentError, invalid_variable_value(db_adapter, "db_adapter", valid_db_adapters) unless valid?(db_adapter, valid_db_adapters)
  end

  before :require_recipes, :validate_required_variables
  
  require "railsmachine/recipes/app/deploy"
  require "railsmachine/recipes/app/mongrel"
  require "railsmachine/recipes/app/passenger"
  
  # defer requires until variables have been set
  task :require_recipes do
    require "railsmachine/recipes/scm/#{scm}"
    require "railsmachine/recipes/web/#{httpd}"
    require "railsmachine/recipes/db/#{db_adapter}"
  end
  
  namespace :servers do
  
    desc <<-DESC
    A macro task that calls setup for db, app, symlinks, and web.
    Used to configure your deployment environment in one command.
    DESC
    task :setup  do
      sudo  "chown -R #{user}:#{user} #{deploy_to.gsub(application,'')}"
      deploy.setup
    begin
      db.setup
    rescue
      puts "db:setup failed!"
    end
      app.setup
      web.setup
    end
  
    desc "A macro task that restarts the application and web servers"
    task :restart do
      app.restart
      web.restart
    end
  
  end
  
  namespace :app do
  
    desc "Setup #{app_server}"
    task :setup, :roles => :app  do
      case app_server.to_s
       when "mongrel"
        setup_mongrel
       when "passenger"
        setup_passenger
      end
    end
    
    desc "Restart application server."
    task :restart, :roles => :app  do
      case app_server.to_s
       when "mongrel"
        restart_mongrel
       when "passenger"
        restart_passenger
      end
    end
    
    desc "Start application server."
    task :start, :roles => :app  do
      case app_server.to_s
       when "mongrel"
        start_mongrel
       when "passenger"
        start_passenger
      end
    end
    
    desc "Stop application server."
    task :stop, :roles => :app  do
      case app_server.to_s
       when "mongrel"
        stop_mongrel
       when "passenger"
        stop_passenger
      end
    end
    
    desc "Switch your application to run on mongrel or passenger."
    task :switch do
      case app_server.to_s
       when "mongrel"
         switch_to_mongrel
       when "passenger"
         switch_to_passenger
      end
    end
  
    namespace :symlinks do
  
      desc "Setup application symlinks in the public"
      task :setup, :roles => [:app, :web] do
        if app_symlinks
          app_symlinks.each { |link| run "mkdir -p #{shared_path}/public/#{link}" }
        end
      end

      desc "Link public directories to shared location."
      task :update, :roles => [:app, :web] do
        if app_symlinks
          app_symlinks.each { |link| run "ln -nfs #{shared_path}/public/#{link} #{current_path}/public/#{link}" }
        end
      end
  
    end
  
  end
  
  namespace :web do
    
    desc "Setup web server."
    task :setup, :roles => :web  do
      set :httpd_server_name, domain unless httpd_server_name
      apache.configure
    end
    
    desc "Restart web server."
    task :restart, :roles => :web  do
      apache.restart
    end
    
    desc "Reload web server configuration."
    task :reload, :roles => :web  do
      apache.reload
    end
    
    desc "Start web server."
    task :start, :roles => :web  do
      apache.start
    end
    
    desc "Stop web server."
    task :stop, :roles => :web  do
      apache.stop
    end  
  
  end
  
  namespace :repos do
    desc "Setup source control repository."
    task :setup, :roles => :scm  do
    begin
      sudo  "chown -R #{user}:#{user} #{deploy_to.gsub(application,'')}"
      localrepo.setup
    rescue
      puts "repos:setup failed!"
    end
      localrepo.import
    end
  
  end
  
  on      :start, :require_recipes
  before  'deploy:update_code', 'app:symlinks:setup'
  after   'deploy:symlink', 'app:symlinks:update'
  after   'deploy:cold', 'web:reload'
  after   :deploy,'deploy:cleanup'
  
  def setup_mongrel
    set_mongrel_conf
    set :mongrel_environment, rails_env
    set :mongrel_port, httpd_proxy_port
    set :mongrel_servers, httpd_proxy_servers
    set :mongrel_user, user unless mongrel_user
    set :mongrel_group, mongrel_user unless mongrel_group
    mongrel.cluster.configure
  end

  def restart_mongrel
    set_mongrel_conf
    mongrel.cluster.restart
  end
  
  def start_mongrel
    set_mongrel_conf
    mongrel.cluster.start
  end

  def stop_mongrel
    set_mongrel_conf
    mongrel.cluster.stop
  end

  def setup_passenger
    set :pasenger_environment, rails_env
    set :passenger_user, user unless passenger_user
    set :passenger_group, passenger_user unless passenger_group
  end

  def restart_passenger
    passenger.restart
  end
  
  def start_passenger
    passenger.start
  end

  def stop_passenger
    passenger.stop
  end
  
  def switch_to_mongrel
    app.setup 
    app.start 
    web.setup
    web.restart
  end
  
  def switch_to_passenger
    web.setup 
    mongrel.cluster.remove 
    web.restart
  end

  def invalid_variable_value(value, name, valid_options)
    error_msg("'#{value}' is not a valid :#{name}.  Please set :#{name} to one of the following: #{valid_options.join(", ")}")
  end

  def error_msg(msg)
    banner = ''; msg.length.times { banner << "+" }
    return "\n\n#{banner}\n#{msg}\n#{banner}\n\n"
  end

  def valid?(value, collection)
    collection.collect { |i| i.to_s }.include? value.to_s
  end
end
