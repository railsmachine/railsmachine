class RailsmachineGenerator < Rails::Generator::NamedBase
  attr_reader :application_name
  attr_reader :domain_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    @application_name = self.file_name
    @domain_name = @args[0]
  end

  def manifest
    record do |m|
      m.directory "config"
      m.template "deploy.rb", File.join("config", "deploy.rb")
    end
  end

  protected

    # Override with your own usage banner.
    def banner
      "Usage: #{$0} railsmachine ApplicationName DomainName"
    end
end