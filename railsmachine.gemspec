Gem::Specification.new do |s|
  s.name = "railsmachine"
  s.version = "1.0.3"
  s.date = "2008-12-18"
  s.description = "The Rails Machine task library"
  s.summary = "The Rails Machine task library"
  s.email = "support@railsmachine.com"
  s.authors = ["Rails Machine"]
  s.homepage = "http://railsmachine.com/"
  s.rubyforge_project = "railsmachine"

  s.files = [
    "bin/railsmachine",
    "lib/railsmachine",
    "lib/railsmachine/generators/loader.rb",
    "lib/railsmachine/generators/railsmachine",
    "lib/railsmachine/generators/railsmachine/railsmachine_generator.rb",
    "lib/railsmachine/generators/railsmachine/templates",
    "lib/railsmachine/generators/railsmachine/templates/deploy.rb",
    "lib/railsmachine/generators/railsmachine/USAGE",
    "lib/railsmachine/recipes/app/deploy.rb",
    "lib/railsmachine/recipes/app/mongrel.rb",
    "lib/railsmachine/recipes/app/passenger.rb",
    "lib/railsmachine/recipes/db/mysql.rb",
    "lib/railsmachine/recipes/db/postgresql.rb",
    "lib/railsmachine/recipes/db/sqlite3.rb",
    "lib/railsmachine/recipes/scm/git.rb",
    "lib/railsmachine/recipes/scm/subversion.rb",
    "lib/railsmachine/recipes/web/apache.rb",
    "lib/railsmachine/recipes/web/templates",
    "lib/railsmachine/recipes/web/templates/mongrel/httpd-ssl.conf",
    "lib/railsmachine/recipes/web/templates/mongrel/httpd.conf",
    "lib/railsmachine/recipes/web/templates/passenger/httpd-ssl.conf",
    "lib/railsmachine/recipes/web/templates/passenger/httpd.conf",
    "lib/railsmachine/recipes.rb",
    "resources/defaults.yaml",
    "tools/rakehelp.rb",
    "README.textile",
    "LICENSE",
    "COPYING"
  ]

  s.has_rdoc = false
  s.require_paths = ["lib"]
  s.executables = ["railsmachine"]
  s.default_executable = %q{railsmachine}

  s.add_dependency('capistrano', ['>= 2.1.0'])
end