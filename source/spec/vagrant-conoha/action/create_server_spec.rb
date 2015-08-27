require 'vagrant-conoha/spec_helper'
require 'ostruct'
require 'sshkey'

include VagrantPlugins::ConoHa::Action
include VagrantPlugins::ConoHa::HttpUtils
include VagrantPlugins::ConoHa::Domain

describe VagrantPlugins::ConoHa::Action::CreateServer do
  let(:config) do
    double('config').tap do |config|
      config.stub(:tenant_name) { 'testTenant' }
      config.stub(:server_name) { 'testName' }
      config.stub(:image) { 'ubuntu' }
      config.stub(:volume_boot) { nil }
      config.stub(:availability_zone) { nil }
      config.stub(:scheduler_hints) { nil }
      config.stub(:security_groups) { nil }
      config.stub(:user_data) { nil }
      config.stub(:admin_pass) { 'TestPassword1234*' }
      config.stub(:metadata) { nil }
    end
  end

  let(:image) do
    double('image').tap do |image|
      image.stub(:name) { 'image_name' }
      image.stub(:id) { 'image123' }
    end
  end

  let(:flavor) do
    double('flavor').tap do |flavor|
      flavor.stub(:name) { 'flavor_name'  }
      flavor.stub(:id) { 'flavor123' }
    end
  end

  let(:nova) do
    double('nova')
  end

  let(:env) do
    {}.tap do |env|
      env[:ui] = double('ui')
      env[:ui].stub(:info).with(anything)
      env[:machine] = double('machine')
      env[:machine] = OpenStruct.new.tap do |m|
        m.provider_config = config
        m.id = nil
      end
      env[:openstack_client] = double('openstack_client')
      env[:openstack_client].stub(:nova) { nova }
    end
  end

  let(:resolver) do
    double('resolver').tap do |r|
      r.stub(:resolve_flavor).with(anything) do
        Flavor.new('flavor-01', 'small', nil, nil, nil)
      end
      r.stub(:resolve_image).with(anything) do
        Item.new('image-01', 'ubuntu')
      end
      r.stub(:resolve_volume_boot).with(anything) { 'ubuntu-drive' }
      r.stub(:resolve_networks).with(anything) { 'net-001' }
      r.stub(:resolve_volumes).with(anything) do
        [{ id: 'vol-01', device: nil }]
      end
      r.stub(:resolve_keypair).with(anything) { 'key' }
      r.stub(:resolve_security_groups).with(anything) do
        [{ name: 'group1' }, { name: 'group2' }]
      end
    end
  end

  let(:utils) do
    double('utils').tap do |u|
      u.stub(:get_ip_address) { '1.2.3.4' }
    end
  end

  before :each do
    CreateServer.send(:public, *CreateServer.private_instance_methods)
    app = double('app')
    app.stub(:call).with(anything)
    @action = CreateServer.new(app, nil, resolver, utils)
  end

  describe 'call' do
    context 'with both image and volume_boot specified' do
      it 'should raise an error' do
        config.stub(:image) { 'linux-image' }
        config.stub(:volume_boot) { 'linux-volume' }
        expect { @action.call(env) }.to raise_error Errors::ConflictBootOption
      end
    end
    context 'with neither image nor volume_boot specified' do
      it 'should raise an error' do
        config.stub(:image) { nil }
        config.stub(:volume_boot) { nil }
        expect { @action.call(env) }.to raise_error Errors::MissingBootOption
      end
    end
    context 'with full options' do
      it 'works' do
        allow(@action).to receive(:create_server).and_return('45678')
        allow(@action).to receive(:waiting_for_server_to_be_built)
        allow(@action).to receive(:attach_volumes)
        allow(@action).to receive(:waiting_for_server_to_be_reachable)

        expect(@action).to receive(:waiting_for_server_to_be_built).with(env, '45678')
        expect(@action).to receive(:attach_volumes).with(env, '45678', [{ id: 'vol-01', device: nil }])

        @action.call(env)
      end
    end
  end

  describe 'create_server' do
    context 'with all options specified' do
      it 'calls nova with all the options' do
        nova.stub(:create_server).with(
          env,
          name: 'testName',
          flavor_ref: flavor.id,
          image_ref: image.id,
          volume_boot: nil,
          networks: [{ uuid: 'test-networks-1' }, { uuid: 'test-networks-2', fixed_ip: '1.2.3.4' }],
          keypair: 'test-keypair',
          availability_zone: 'test-az',
          scheduler_hints: 'test-sched-hints',
          security_groups: ['test-sec-groups'],
          user_data: 'test-user_data',
          admin_pass: 'TestPassword1234*',
          metadata: 'test-metadata') do
          '1234'
        end

        options = {
          flavor: flavor,
          image: image,
          networks: [{ uuid: 'test-networks-1' }, { uuid: 'test-networks-2', fixed_ip: '1.2.3.4' }],
          volumes: [{ id: '001', device: :auto }, { id: '002', device: '/dev/vdc' }],
          keypair_name: 'test-keypair',
          availability_zone: 'test-az',
          scheduler_hints: 'test-sched-hints',
          security_groups: ['test-sec-groups'],
          user_data: 'test-user_data',
          admin_pass: 'TestPassword1234*',
          metadata: 'test-metadata'
        }

        expect(@action.create_server(env, options)).to eq '1234'
      end
    end
    context 'with minimal configuration and a single network' do
      it 'calls nova' do
        config.stub(:server_name) { nil }
        nova.stub(:create_server).with(
          env,
          name: nil,
          flavor_ref: flavor.id,
          image_ref: image.id,
          volume_boot: nil,
          networks: [{ uuid: 'test-networks-1' }],
          keypair: 'test-keypair',
          availability_zone: nil,
          scheduler_hints: nil,
          security_groups: [],
          user_data: nil,
          admin_pass: nil,
          metadata: nil) do
          '1234'
        end

        options = {
          flavor: flavor,
          image: image,
          networks: [{ uuid: 'test-networks-1' }],
          volumes: [],
          keypair_name: 'test-keypair',
          availability_zone: nil,
          scheduler_hints: nil,
          security_groups: [],
          user_data: nil,
          admin_pass: nil,
          metadata: nil
        }

        expect(@action.create_server(env, options)).to eq '1234'
      end
    end
  end

  describe 'waiting_for_server_to_be_built' do
    context 'when server is not yet active' do
      it 'become active after one retry' do
        nova.stub(:get_server_details).and_return({ 'status' => 'BUILD' }, 'status' => 'ACTIVE')
        nova.should_receive(:get_server_details).with(env, 'server-01').exactly(2).times
        config.stub(:server_create_timeout) { 5 }
        @action.waiting_for_server_to_be_built(env, 'server-01', 1)
      end
      it 'timeout before the server become active' do
        nova.stub(:get_server_details).and_return({ 'status' => 'BUILD' }, 'status' => 'BUILD')
        nova.should_receive(:get_server_details).with(env, 'server-01').at_least(2).times
        config.stub(:server_create_timeout) { 3 }
        expect { @action.waiting_for_server_to_be_built(env, 'server-01', 1) }.to raise_error Errors::Timeout
      end
      it 'raise an error after one retry' do
        nova.stub(:get_server_details).and_return({ 'status' => 'BUILD' }, 'status' => 'ERROR')
        nova.should_receive(:get_server_details).with(env, 'server-01').exactly(2).times
        config.stub(:server_create_timeout) { 3 }
        expect { @action.waiting_for_server_to_be_built(env, 'server-01', 1) }.to raise_error Errors::ServerStatusError
      end
    end
  end

  describe 'attach_volumes' do
    context 'with volume attached in all possible ways' do
      it 'returns normalized volume list' do
        nova.stub(:attach_volume).with(anything, anything, anything, anything) {}
        nova.should_receive(:attach_volume).with(env, 'server-01', '001', nil)
        nova.should_receive(:attach_volume).with(env, 'server-01', '002', '/dev/vdb')

        @action.attach_volumes(env, 'server-01', [{ id: '001', device: nil }, { id: '002', device: '/dev/vdb' }])
      end
    end
  end
end
