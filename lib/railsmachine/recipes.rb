Capistrano::Configuration.instance(:must_exist).load do

  default_run_options[:pty] = true
  set :keep_releases, 3
  set :app_symlinks, nil

  set :scm, :subversion
  set :valid_scms, [:subversion, :git]

  set :httpd, :apache
  set :valid_httpds, [:apache]

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
  
    desc <<-DESC
    A macro task that restarts the application and web servers
    DESC
    task :restart do
      app.restart
      web.restart
    end
  
  end
  
  namespace :app do
  
    desc <<-DESC
    Setup #{app_server}
    DESC
    task :setup, :roles => :app  do
      case app_server.to_s
       when "mongrel"
        setup_mongrel
       when "passenger"
        # do nothing
      end
    end
    
    desc <<-DESC
    Restart application server.
    DESC
    task :restart, :roles => :app  do
      application_servlet.restart
    end
    
    desc <<-DESC
    Start application server.
    DESC
    task :start, :roles => :app  do
      application_servlet.start
    end
    
    desc <<-DESC
    Stop application server.
    DESC
    task :stop, :roles => :app  do
      application_servlet.stop
    end
    
    desc <<-DESC
    Switch your application to run on mongrel or passenger.
    DESC
    task :switch do
      case app_server.to_s
       when "mongrel"
         switch_to_mongrel
       when "passenger"
         switch_to_passenger
      end
    end
  
    namespace :symlinks do
  
      desc <<-DESC
      Setup application symlinks in the public
      DESC
      task :setup, :roles => [:app, :web] do
        if app_symlinks
          app_symlinks.each { |link| run "mkdir -p #{shared_path}/public/#{link}" }
        end
      end

      desc <<-DESC
      Link public directories to shared location.
      DESC
      task :update, :roles => [:app, :web] do
        if app_symlinks
          app_symlinks.each { |link| run "ln -nfs #{shared_path}/public/#{link} #{current_path}/public/#{link}" }
        end
      end
  
    end
  
  end
  
  namespace :web do
    
    desc <<-DESC
    Setup web server.
    DESC
    task :setup, :roles => :web  do
      set :apache_server_name, domain unless  apache_server_name
      apache.configure
    end
    
    desc <<-DESC
    Restart web server.
    DESC
    task :restart, :roles => :web  do
      apache.restart
    end
    
    desc <<-DESC
    Reload web server configuration.
    DESC
    task :reload, :roles => :web  do
      apache.reload
    end
    
    desc <<-DESC
    Start web server.
    DESC
    task :start, :roles => :web  do
      apache.start
    end
    
    desc <<-DESC
    Stop web server.
    DESC
    task :stop, :roles => :web  do
      apache.stop
    end  
  
  end
  
  namespace :repos do
    desc <<-DESC
    Setup source control repository.
    DESC
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
    set :mongrel_port,  apache_proxy_port
    set :mongrel_servers,  apache_proxy_servers
    set :mongrel_user, user unless mongrel_user
    set :mongrel_group, mongrel_user unless mongrel_group
    mongrel.cluster.configure
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
  
  def application_servlet
    case app_server.to_s
      when 'mongrel' 
        mongrel.cluster
      when 'passenger' 
        passenger
    end 
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
