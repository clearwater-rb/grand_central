module GrandCentral
  class Action
    def self.with_attributes *attributes, &body
      klass = Class.new(self)
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
  end
end
