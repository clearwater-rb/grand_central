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

    def self.deserialize hash, namespace: Object
      attributes = hash.each_with_object({}) do |(key, value), hash|
        hash[key] = case value
                    when Hash
                      if klass = value['$class']
                        case klass
                        when 'Time'
                          Time.at(value['value'])
                        else
                          deserialize value, namespace: namespace
                        end
                      else
                        value
                      end
                    else
                      value
                    end
      end

      namespace.const_get(hash.fetch('$class')).new(attributes)
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

    def == other
      return false if self.class.attributes != other.class.attributes

      self.class.attributes.each do |attr|
        return false if send(attr) != other.send(attr)
      end

      true
    end

    def to_serializable_format
      serialized = to_h.each_with_object({}) do |(key, value), hash|
        hash[key] = case value
                    when Time
                      {
                        '$class' => 'Time',
                        value: value.to_f,
                      }
                    when GrandCentral::Model
                      value.to_h.merge('$class' => value.class.name)
                    else
                      value
                    end
      end

      serialized['$class'] = self.class.name
      serialized
    end
  end
end
