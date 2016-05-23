require 'log4r'

require 'vagrant/action/builder'

require 'vagrant-conoha/action/abstract_action'
require 'vagrant-conoha/action/read_ssh_info'

module VagrantPlugins
  module ConoHa
    module Action
      include Vagrant::Action::Builtin

      class ProvisionWrapper < AbstractAction
        def initialize(app, env)
          @app    = app
          @env    = env
          @logger = Log4r::Logger.new('vagrant_openstack::action::provision_wrapper')
        end

        def execute(env)
          @logger.info 'Run provisioning'
          InternalProvisionWrapper.new(@app, @env).call(@env)
          @app.call(env)
        end
      end

      class InternalProvisionWrapper < Vagrant::Action::Builtin::Provision
        def initialize(app, env)
          @logger = Log4r::Logger.new('vagrant_openstack::action::internal_provision_wrapper')
          super app, env
        end

        def run_provisioner(env)
          if env[:provisioner].is_a?(Vagrant.plugin('2').manager.provisioners[:shell])
            handle_shell_meta_args(env)
          end
          env[:provisioner].provision
        end

        private

        def handle_shell_meta_args(env)
          config = env[:provisioner].config
          args = config.args.nil? ? [] : [config.args].flatten
          config.args = []
          @logger.info "Shell provisioner args: #{args}"
          args.each do |arg|
            if '@@ssh_ip@@'.eql? arg
              ssh_info = VagrantPlugins::ConoHa::Action.get_ssh_info(env)
              @logger.info "Replace meta-arg #{arg} by value #{ssh_info[:host]}"
              config.args << ssh_info[:host]
            else
              config.args << arg
            end
          end
        end
      end
    end
  end
end
