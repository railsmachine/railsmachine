Capistrano::Configuration.instance(:must_exist).load do
  namespace :install do
    desc "Install Phusion Passenger"
      task :passenger, :roles => :web do
        install_passenger_dependencies
        install_passenger_module
        config_passenger
      end

      task :install_passenger_dependencies, :roles => :web do
        sudo "yum install gcc-c++ httpd-devel -y"
        sudo "gem install rack --no-ri --no-rdoc"
      end

      task :install_passenger_module, :roles => :web do
        sudo "gem install passenger --no-ri --no-rdoc"
        run "yes | sudo passenger-install-apache2-module"
      end

      task :config_passenger, :roles => :web do
        version = 'ERROR'
        arch = ''
        rubypath = '/usr/bin/ruby'
      
        run("gem list | grep passenger") do |ch, stream, data|
          version = data.sub(/passenger \(([^),]+).*/,"\\1").strip
        end
      
        run("which ruby") do |ch, stream, data|
          rubypath = data.strip
        end
      
        run("uname -i") do |ch, stream, data|
          arch = '64' if data.strip == "x86_64"
        end
      
        puts "    passenger version #{version} configured for #{arch}"        
      
        file = File.join(File.dirname(__FILE__),"../", "web", "templates", "passenger", "passenger.conf")
        template = File.read(file)
        passenger_config = ERB.new(template).result(binding)
      
        # make the conf
        put passenger_config, "/tmp/passenger.conf"
        send(run_method, "cp /tmp/passenger.conf /etc/httpd/conf/passenger.conf")
        send(run_method, "rm -f /tmp/passenger.conf")

        # include in apache
        sudo("chmod 666 /etc/httpd/conf/httpd.conf")
        sudo("[  -z \"`grep 'Include conf/passenger.conf' /etc/httpd/conf/httpd.conf`\" ] && echo 'Include conf/passenger.conf' >> /etc/httpd/conf/httpd.conf || echo 'Passenger module already included.'")
        sudo("chmod 644 /etc/httpd/conf/httpd.conf")
    
      end
  end
end