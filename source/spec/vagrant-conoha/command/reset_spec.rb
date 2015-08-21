require 'vagrant-conoha/spec_helper'

describe VagrantPlugins::ConoHa::Command::Reset do
  describe 'cmd' do
    let(:env) do
      {}.tap do |env|
        env[:ui] = double('ui')
        env[:ui].stub(:info).with(anything)
        env[:machine] = double('machine')
        env[:machine].stub(:data_dir) { '/my/data/dir' }
      end
    end

    before :each do
      @reset_cmd = VagrantPlugins::ConoHa::Command::Reset.new(nil, env)
    end

    it 'resets vagrant openstack machines' do
      expect(env[:ui]).to receive(:info).with('Vagrant ConoHa has been reset.')
      expect(FileUtils).to receive(:remove_dir).with('/my/data/dir')
      @reset_cmd.cmd('reset', [], env)
    end
  end
end
