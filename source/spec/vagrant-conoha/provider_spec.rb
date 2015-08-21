require 'vagrant-conoha/spec_helper'

describe VagrantPlugins::ConoHa::Provider do
  before :each do
    @provider = VagrantPlugins::ConoHa::Provider.new :machine
  end

  describe 'to string' do
    it 'should give the provider name' do
      @provider.to_s.should eq('Vagrant ConoHa provider')
    end
  end
end
