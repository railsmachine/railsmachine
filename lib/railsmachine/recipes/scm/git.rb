require 'fileutils'
Capistrano::Configuration.instance(:must_exist).load do

  namespace :localrepo do

    desc "Setup directory structure and initialize git repository on remote server"
    task :setup, :roles => :scm do
      dir =  "#{deploy_to}/repos/#{application}.git"
      run   "mkdir -p #{dir}"
      sudo  "chown -R #{user}:#{user} #{dir}"
      run   "cd #{dir} && git --bare init"
      run   "chmod 770 #{dir}"
    end

    desc "Import code into remote git repository."
    task :import  do
      puts    "Initializing local git repository"
      system  "git init" unless File.directory?(".git")

      puts    "Adding remote server pointing to #{repository}"
      remotes = `git remote`.split("\n").map {|r| `git remote show #{r}`}
      remote_name = if existing_remote = remotes.find {|r| r =~ /URL: #{Regexp.escape(repository)}/ }
        existing_remote.match(/\* remote (.*)$/)[1]
      elsif remotes.any? {|r| r =~ /\* remote origin$/ }
        Capistrano::CLI.ui.ask("Remote 'origin' already exists.  Please name the remote you want to create:")
      else
        'origin'
      end
      unless existing_remote
        system  "git remote add #{remote_name} #{repository}"
      end

      puts "Adding .gitignore file"
      ignores = File.exist?('.gitignore') ? File.read('.gitignore') : ''
      system "echo 'log/*'>> .gitignore"             unless ignores =~ %r{log/\*}
      system "echo 'tmp/*'>> .gitignore"             unless ignores =~ %r{tmp/\*}
      system "echo '.DS_Store'>> .gitignore"         unless ignores =~ %r{\.DS_Store}
      system "echo 'public/cache/**/*'>> .gitignore" unless ignores =~ %r{public/cache/\*\*/\*}
      system "git add .gitignore && git commit -v -m 'Add ignores.'"  if `git status` =~ %r{\.gitignore}

      unless `git status` =~ /working directory clean/
        puts "Committing application locally"
        system "git add *"
        system 'git commit -a -v -m "Import for RailsMachine"'
      end

      puts "Pushing application to the remote server '#{remote_name}'."
      system  "git push #{remote_name} master"

      puts "git setup complete"
      puts "You can clone this repository with git clone #{repository} #{application}"
    end

  end

end