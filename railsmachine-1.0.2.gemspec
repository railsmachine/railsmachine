Gem::Specification.new do |s|
  s.name = %q{railsmachine}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  
  s.date = %q{2008-10-17}
  s.description = %q{The Rails Machine task library}
  s.summary = %q{The Rails Machine task library}
  
  s.extra_rdoc_files = ["README"]
  s.files = Dir.glob("{bin,lib,resources,tools}/**/*") + %w(README LICENSE COPYING)
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  
  s.bindir = "bin"
  s.executables = ["railsmachine"]
  s.default_executable = %q{railsmachine}
  s.add_dependency('capistrano', '>= 2.1.0')
  
  s.authors = ["Rails Machine"]
  s.email = "support@railsmachine.com"
  s.homepage = "http://railsmachine.com/"
  s.rubyforge_project = "railsmachine"
end
