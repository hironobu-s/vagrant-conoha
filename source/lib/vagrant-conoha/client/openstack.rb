require 'log4r'
require 'json'

require 'vagrant-conoha/client/heat'
require 'vagrant-conoha/client/keystone'
require 'vagrant-conoha/client/nova'
require 'vagrant-conoha/client/neutron'
require 'vagrant-conoha/client/cinder'
require 'vagrant-conoha/client/glance'

module VagrantPlugins
  module ConoHa
    class Session
      include Singleton

      attr_accessor :token
      attr_accessor :project_id
      attr_accessor :endpoints

      def initialize
        @token = nil
        @project_id = nil
        @endpoints = {}
      end

      def reset
        initialize
      end
    end

    def self.session
      Session.instance
    end

    def self.keystone
      ConoHa::KeystoneClient.instance
    end

    def self.nova
      ConoHa::NovaClient.instance
    end

    def self.heat
      ConoHa::HeatClient.instance
    end

    def self.neutron
      ConoHa::NeutronClient.instance
    end

    def self.cinder
      ConoHa::CinderClient.instance
    end

    def self.glance
      ConoHa::GlanceClient.instance
    end
  end
end
