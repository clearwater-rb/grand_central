require 'grand_central/model'

module GrandCentral
  class Action
    def self.with_attributes *attributes, &body
      klass = Class.new(self)
      klass.instance_exec { @attributes = attributes }
      klass.send :define_method, :initialize do |*args|
        attributes.each_with_index do |attribute, index|
          instance_variable_set "@#{attribute}", args[index]
        end
      end
      klass.send :attr_reader, *attributes
      klass.class_exec &body if block_given?

      klass
    end

    def self.create &block
      with_attributes &block
    end

    def then &block
      promise.then &block
    end

    def fail &block
      promise.fail &block
    end

    def always &block
      promise.always &block
    end

    def to_serializable_format
      hash = { '$class' => self.class.name }

      self.class.attributes.each do |attr|
        hash[attr.to_s] = public_send(attr)
      end

      hash
    end

    def self.deserialize serialized, namespace: Object
      klass = namespace.const_get(serialized.fetch('$class'))
      action = klass.allocate

      serialized.each do |attribute, value|
        unless attribute.to_s[0] == '$'
          value = case value
                  when Model, Action
                    value.class.deserialize(value, namespace: namespace)
                  else
                    value
                  end
          action.instance_variable_set "@#{attribute}", value
        end
      end

      action
    end

    def self.attributes
      @attributes
    end
  end
end
