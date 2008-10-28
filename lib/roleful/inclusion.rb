module Roleful  
  def self.included(base)
    base.class_eval do
      extend(ClassMethods)
      include(InstanceMethods)
      const_set("ROLES", { })
      define_role(:null)
    end
  end
  
  module InstanceMethods
    private
    
    def role_proxy
      name = role.to_sym rescue :null
      self.class::ROLES[name || :null]
    end
  end
  
  module ClassMethods
    def role(name, options={}, &block)
      define_role(name.to_sym, options, &block)
    end
    
    private
    
    def define_role(name, options={}, &block)
      self::ROLES[name] ||= Role.new(self, name, options)
      self::ROLES[name].enhance(&block) if block_given?
    end
  end
end