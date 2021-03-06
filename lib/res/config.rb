require 'yaml'

module Res
  class Config
    attr_accessor :struct, :required, :optional, :prepend

    def initialize(items, args = {})
      @required = *items
      @optional = args[:optional] || []
      @prepend  = args[:pre_env] || ''
      items     = required + optional
      @struct   = Struct.new(*items).new
    end

    # Load in config -- this can come from three places:
    # 1. Arguments passed to the initializer
    # 2. From environment variables
    # 3. From a config file
    def process(args = {})
      config_from_file = {}
      if args[:config_file]
        config_from_file = load_from_config(args[:config_file])
        args.delete(:config_file)
      end

      missing = []
      struct.members.each do |item|
        struct[item] = args[item] || ENV[(prepend + item.to_s).upcase] || config_from_file[item] || nil
        missing << item if struct[item].nil? && required.include?(item)
      end
      raise 'Missing configuration: ' + missing.join(', ') if missing.any?
    end

    def load_from_config(config_file)
      config = {}
      raise "Couldn't find config file '#{config_file}'" unless File.exist?(config_file)
      config = Res::Config.symbolize_keys(YAML.safe_load(File.open(config_file)))
      config
    end

    def self.symbolize_keys(hash)
      symbolized_hash = {}
      hash.each do |key, value|
        symbolized_hash[key.to_sym] = value
      end
      symbolized_hash
    end

    def method_missing(m, *args, &block)
      struct.send(m, *args, &block)
    end
  end
end
