require 'vagrant-conoha/command/utils'
require 'vagrant-conoha/command/abstract_command'

module VagrantPlugins
  module ConoHa
    module Command
      class Reset < AbstractCommand
        def self.synopsis
          I18n.t('vagrant_openstack.command.reset')
        end

        def cmd(name, argv, env)
          fail Errors::NoArgRequiredForCommand, cmd: name unless argv.size == 0
          FileUtils.remove_dir("#{env[:machine].data_dir}")
          env[:ui].info 'Vagrant ConoHa has been reset.'
        end
      end
    end
  end
end
