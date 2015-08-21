
if ENV['COVERAGE'] != 'false'
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter 'spec'
  end
end

Dir[
  'lib/vagrant-conoha/version_checker.rb',
  'lib/vagrant-conoha/logging.rb',
  'lib/vagrant-conoha/config.rb',
  'lib/vagrant-conoha/config_resolver.rb',
  'lib/vagrant-conoha/utils.rb',
  'lib/vagrant-conoha/errors.rb',
  'lib/vagrant-conoha/provider.rb',
  'lib/vagrant-conoha/client/*.rb',
  'lib/vagrant-conoha/command/*.rb',
  'lib/vagrant-conoha/action/*.rb'].each { |file| require file[4, file.length - 1] }

require 'rspec/its'
require 'webmock/rspec'
require 'fakefs/safe'
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end

I18n.load_path << File.expand_path('locales/en.yml', Pathname.new(File.expand_path('../../../', __FILE__)))

VagrantPlugins::ConoHa::Logging.init
