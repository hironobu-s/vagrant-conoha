require 'log4r'
require 'json'

require 'vagrant-conoha/client/http_utils'
require 'vagrant-conoha/client/domain'

module VagrantPlugins
  module ConoHa
    class NeutronClient
      include Singleton
      include VagrantPlugins::ConoHa::HttpUtils
      include VagrantPlugins::ConoHa::Domain

      def initialize
        @logger = Log4r::Logger.new('vagrant_openstack::neutron')
        @session = VagrantPlugins::ConoHa.session
      end

      def get_private_networks(env)
        get_networks(env, false)
      end

      def get_all_networks(env)
        get_networks(env, true)
      end

      def get_subnets(env)
        subnets_json = get(env, "#{@session.endpoints[:network]}/subnets")
        subnets = []
        JSON.parse(subnets_json)['subnets'].each do |n|
          subnets << Subnet.new(n['id'], n['name'], n['cidr'], n['enable_dhcp'], n['network_id'])
        end
        subnets
      end

      private

      def get_networks(env, all)
        networks_json = get(env, "#{@session.endpoints[:network]}/networks")
        networks = []
        JSON.parse(networks_json)['networks'].each do |n|
          networks << Item.new(n['id'], n['name']) if all || n['tenant_id'].eql?(@session.project_id)
        end
        networks
      end
    end
  end
end
