module RailsMachine
  module Generators
    class RailsLoader
      def self.load!(options)
        require "#{options[:apply_to]}/config/environment"
        require "rails_generator"
        require "rails_generator/scripts/generate"

        Rails::Generator::Base.sources << Rails::Generator::PathSource.new(
          :railsmachine, File.dirname(__FILE__))

        args = ["railsmachine"]
        args << (options[:application] || "Application")
        args << (options[:domain] || "my.railsmachina.com")

        Rails::Generator::Scripts::Generate.new.run(args)
      end
    end
  end
end