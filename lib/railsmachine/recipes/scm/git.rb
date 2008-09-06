# require 'fileutils'
# Capistrano::Configuration.instance(:must_exist).load do
#  
#   namespace :scm do
#      
#     desc "Setup directory structure and initialize git repository on remote server"
#     task :setup, :roles => :scm do
#       dir =  "#{deploy_to}/repos"
#       run   "mkdir -p #{dir}"
#       sudo  "chown -R deploy:deploy #{dir}"
#       run   "cd #{dir} && git --bare init"
#       run   "chmod 770 #{dir}"
#     end
# 
#     desc "Import code into remote git repository."
#     task :import  do
#       puts    "Initializing local git repository"
#       system  "git init"
# 
#       puts    "Adding remote server pointing to #{repository}"
#       system  "git remote add origin #{repository}"
# 
#       puts "Adding .gitignore file"
#       system "echo 'log/*'>> .gitignore"
#       system "echo 'tmp/*'>> .gitignore"
#       system "echo '.DS_Store'>> .gitignore"
#       system "echo 'public/cache/**/*'>> .gitignore"
#       system "git add .gitignore"
# 
#       puts "Committing application locally"
#       system "git add *"
#       system 'git commit -a -v -m "initial import of site"'
# 
#       puts "Pushing application to the remote server.  The name of the branch is:"
#       system  "git remote"
#       system  "git push origin master"
#       puts "Creating edge branch on remote"
#       system "git push origin master:refs/heads/edge"
#       puts "create a local tracking edge branch"
#       system "git branch --track edge origin/edge"
#       puts "checking out edge repository"
#       system "git checkout edge"
#       puts "git setup complete"
#       puts "You can clone this repository with git clone #{repository} #{application}"
#     end
#  
#   end
#  
# end
