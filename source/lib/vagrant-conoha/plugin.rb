begin
  require 'vagrant'
rescue LoadError
  raise 'The ConoHa provider must be run within Vagrant.'
end

require 'vagrant-conoha/version_checker'

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < '1.4.0'
  fail 'ConoHa provider is only compatible with Vagrant 1.4+'
end

module VagrantPlugins
  module ConoHa
    class Plugin < Vagrant.plugin('2')
      name 'ConoHa'
      description <<-DESC
      This plugin enables Vagrant to manage machines in ConoHa.
      DESC

      config(:conoha, :provider) do
        require_relative 'config'
        Config
      end

      provider(:conoha, box_optional: true) do
        ConoHa.init_i18n
        ConoHa.init_logging
        VagrantPlugins::ConoHa.check_version

        # Load the actual provider
        require_relative 'provider'
        Provider
      end

      command('openstack') do
        ConoHa.init_i18n
        ConoHa.init_logging
        VagrantPlugins::ConoHa.check_version

        require_relative 'command/main'
        Command::Main
      end
    end
  end
end
