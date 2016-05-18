module VagrantPlugins
  module ConoHa
    #
    # Stable versions must respect the pattern given
    # by VagrantPlugins::ConoHa::VERSION_PATTERN
    #
    VERSION = '0.1.5'

    #
    # Stable version must respect the naming convention 'x.y.z'
    # where x, y and z are integers inside the range [0, 999]
    #
    VERSION_PATTERN = /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/
  end
end
