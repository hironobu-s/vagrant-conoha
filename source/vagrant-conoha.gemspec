lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-conoha/version'

Gem::Specification.new do |gem|
  gem.name          = 'vagrant-conoha'
  gem.version       = VagrantPlugins::ConoHa::VERSION
  gem.authors       = ['Hironobu Saitoh']
  gem.email         = ['hiro@hironobu.org']
  gem.description   = 'Enables Vagrant to manage VPS in ConoHa.'
  gem.summary       = 'Enables Vagrant to manage VPS in ConoHa.'
  gem.homepage      = 'https://github.com/hironobu-s/vagrant-conoha/'
  gem.license       = 'MIT'

  gem.add_dependency 'json', '~> 1.8.3'
  gem.add_dependency 'rest-client', '>= 1.6.9'
  gem.add_dependency 'terminal-table', '1.5.2'
  gem.add_dependency 'sshkey', '1.7.0'
  gem.add_dependency 'colorize', '0.7.7'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.1.0'
  gem.add_development_dependency 'rspec-its', '~> 1.0.1'
  gem.add_development_dependency 'rspec-expectations', '~> 3.1.2'
  gem.add_development_dependency 'webmock', '~> 1.18.0'
  gem.add_development_dependency 'fakefs', '~> 0.5.2'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(/^bin\//).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(/^(test|spec|features)\//)
  gem.require_paths = ['lib']
end
