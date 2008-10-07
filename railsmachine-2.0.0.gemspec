Gem::Specification.new do |s|
  s.name = %q{railsmachine}
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bradley Taylor, Rob Lingle"]
  s.date = %q{2008-07-24}
  s.default_executable = %q{railsmachine}
  s.description = %q{The Rails Machine task library}
  s.executables = ["railsmachine"]
  s.bindir = 'bin'
  s.extra_rdoc_files = ["README"]
  s.files = ["bin",
    "bin/railsmachine",
    "COPYING",
    "lib",
    "lib/railsmachine",
    "lib/railsmachine/generators",
    "lib/railsmachine/generators/loader.rb",
    "lib/railsmachine/generators/railsmachine",
    "lib/railsmachine/generators/railsmachine/railsmachine_generator.rb",
    "lib/railsmachine/generators/railsmachine/templates",
    "lib/railsmachine/generators/railsmachine/templates/deploy.rb",
    "lib/railsmachine/generators/railsmachine/USAGE",
    "lib/railsmachine/recipes",
    "lib/railsmachine/recipes/app",
    "lib/railsmachine/recipes/app/mongrel.rb",
    "lib/railsmachine/recipes/app/passenger.rb",
    "lib/railsmachine/recipes/db",
    "lib/railsmachine/recipes/db/mysql.rb",
    "lib/railsmachine/recipes/db/postgresql.rb",
    "lib/railsmachine/recipes/db/sqlite3.rb",
    "lib/railsmachine/recipes/scm",
    "lib/railsmachine/recipes/scm/git.rb",
    "lib/railsmachine/recipes/scm/subversion.rb",
    "lib/railsmachine/recipes/web",
    "lib/railsmachine/recipes/web/apache.rb",
    "lib/railsmachine/recipes/web/nginx.rb",
    "lib/railsmachine/recipes/web/templates",
    "lib/railsmachine/recipes/web/templates/mongrel",
    "lib/railsmachine/recipes/web/templates/mongrel/httpd-ssl.conf",
    "lib/railsmachine/recipes/web/templates/mongrel/httpd.conf",
    "lib/railsmachine/recipes/web/templates/passenger","lib/railsmachine/recipes/web/templates/passenger/httpd-ssl.conf","lib/railsmachine/recipes/web/templates/passenger/httpd.conf","lib/railsmachine/recipes.rb","LICENSE","Rakefile","README","resources","resources/defaults.yaml","tools", "tools/rakehelp.rb"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{2.0.0}
  s.summary = %q{The Rails Machine task library}

  
end
