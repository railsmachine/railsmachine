# CentOS install for Rails Machine
# sudo su -
# yum install postgresql-client postgresql-server postgresql-devel
# chkconfig postgresql on
# service postgresql start
# gem install postgres
# su - postgres
# createuser deploy -a -d 
# exit

require 'yaml'
require 'capistrano'
require 'capistrano/cli'

module PostgreSQLMethods
  
  def createdb(db, user)
    run "createdb -O #{user} #{db}"  
  end
  
  def createuser(user, password)
    cmd = "createuser -P -D -A -E #{user}"
    run cmd do |channel, stream, data|
      if data =~ /^Enter password for new user:/
        channel.send_data "#{password}\n" 
      end
      if data =~ /^Enter it again:/
        channel.send_data "#{password}\n" 
      end
    end
  end
  
  def command(sql, database)
    run "psql --command=\"#{sql}\" #{database}" 
  end
   
end

Capistrano.plugin :pgsql, PostgreSQLMethods

Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :db do
  
    desc "Create PosgreSQL database and user based on config/database.yml"
    task :setup, :roles => :db, :only => { :primary => true } do
      # on_rollback {} TODO
      read_config
      pgsql.createuser db_user, db_password
      pgsql.createdb db_name, db_user
    end
  
  end
  
  def read_config
    db_config = YAML.load_file('config/database.yml')
    set :db_user, db_config[rails_env]["username"]
    set :db_password, db_config[rails_env]["password"] 
    set :db_name, db_config[rails_env]["database"]
  end
  
end
