require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'tools/rakehelp'
require 'fileutils'
include FileUtils

setup_tests
setup_clean ["pkg", "lib/*.bundle", "*.gem", ".config"]

setup_rdoc ['README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc']

desc "Does a full compile, test run"
task :default => [:test, :package]

version="1.0.4"
name="railsmachine"

setup_gem(name, version) do |spec|
  spec.summary = "The Rails Machine task library"
  spec.description = spec.summary
  spec.author="Rails Machine"
  spec.add_dependency('capistrano', '>= 2.1.0')
  spec.has_rdoc = false
  spec.files += Dir.glob("bin/*")
  spec.files += Dir.glob("resources/**/*")
  spec.default_executable = "railsmachine"
  spec.executables = ["railsmachine"]
  spec.email = "support@railsmachine.com"
  spec.homepage = "http://railsmachine.com/"
  spec.rubyforge_project = "railsmachine"
end

task :install => [:test, :package] do
  sh %{sudo gem install pkg/#{name}-#{version}.gem}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{name}}
end

task :gem_source do
  mkdir_p "pkg/gems"

  FileList["**/*.gem"].each { |gem| mv gem, "pkg/gems" }
  FileList["pkg/*.tgz"].each {|tgz| rm tgz }
  rm_rf "pkg/#{name}-#{version}"

  sh %{ generate_yaml_index.rb -d pkg }
  sh %{ scp -r pkg/* #{ENV['SSH_USER']}@rubyforge.org:/var/www/gforge-projects/railsmachine/releases/ }
end
