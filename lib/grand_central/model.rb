require 'set'

module GrandCentral
  class Model
    def self.with_attributes *attrs
      klass = Class.new(self)
      klass.attributes *attrs
      klass
    end

    def self.attributes *attrs
      @attributes ||= Set.new
      if attrs.any?
        @attributes += attrs
        attr_reader *attrs
      end

      @attributes
    end

    def initialize attributes={}
      unless attributes.respond_to? :[]
        raise TypeError, "Must pass in a hash or other object that responds to `[]'. Instead received #{attributes.inspect}"
      end

      self.class.attributes.each do |attr|
        value = attributes[attr] || attributes[attr.to_s]
        instance_variable_set "@#{attr}", value
      end
    end

    def update attributes={}
      return self if attributes.all? { |key, value| respond_to?(key) && send(key) == value }

      new_attrs = self.class.attributes.each_with_object({}) do |attr, hash|
        hash[attr] = attributes.fetch(attr) { send(attr) }
      end

      self.class.new(new_attrs)
    end

    def to_h
      self.class.attributes.each_with_object({}) do |attr, hash|
        hash[attr] = send(attr)
      end
    end
  end
end
