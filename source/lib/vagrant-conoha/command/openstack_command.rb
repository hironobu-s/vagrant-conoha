require 'vagrant-conoha/command/utils'
require 'vagrant-conoha/command/abstract_command'

module VagrantPlugins
  module ConoHa
    module Command
      class OpenstackCommand < AbstractCommand
        include VagrantPlugins::ConoHa::Command::Utils

        def before_cmd(_name, _argv, env)
          VagrantPlugins::ConoHa::Action::ConnectOpenstack.new(nil, env).call(env)
        end
      end
    end
  end
end
