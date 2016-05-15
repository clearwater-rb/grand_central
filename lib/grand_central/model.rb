require 'set'

module GrandCentral
  class Model
    def self.attributes *attrs
      @attributes ||= Set.new
      if attrs.any?
        @attributes += attrs
        attr_reader *attrs
      end

      @attributes
    end

    def initialize attributes={}
      self.class.attributes.each do |attr|
        instance_variable_set "@#{attr}", attributes[attr]
      end
    end

    def update attributes={}
      self.class.new(to_h.merge(attributes))
    end

    def to_h
      self.class.attributes.each_with_object({}) do |attr, hash|
        hash[attr] = send(attr)
      end
    end
  end
end
