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
      unless attributes.respond_to? :[]
        raise TypeError, "Must pass in a hash or other object that responds to `[]'. Instead received #{attributes.inspect}"
      end

      self.class.attributes.each do |attr|
        instance_variable_set "@#{attr}", attributes[attr]
      end
    end

    def update attributes={}
      old_attributes = to_h
      new_attributes = old_attributes.merge(attributes)

      if new_attributes == old_attributes
        self
      else
        self.class.new(new_attributes)
      end
    end

    def to_h
      self.class.attributes.each_with_object({}) do |attr, hash|
        hash[attr] = send(attr)
      end
    end
  end
end
