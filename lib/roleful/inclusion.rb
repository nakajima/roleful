module Roleful  
  def self.included(base)
    base.class_eval do
      extend(ClassMethods)
      include(InstanceMethods)
      const_set("ROLES", { })
      define_null_role
    end
  end
  
  module InstanceMethods
    def role_proxy
      name = role.to_sym rescue :null
      self.class::ROLES[name || :null]
    end
  end
  
  module ClassMethods
    def role(name, &block)
      define_role(name.to_sym, &block)
    end
    
    private
    
    def define_role(name, &block)
      self::ROLES[name] ||= Role.new(self)
      self::ROLES[name].enhance(&block) if block_given?
    end
    
    def get_role(name)
      self::ROLES[name] || self::ROLES[:null]
    end
    
    def define_null_role
      define_role(:null) do
        def self.method_missing(sym, *args)
          method_id = sym.to_s
          method_id.match(/can_[a-zA-Z_]+\?/) ? false : super
        end
      end
    end
  end
end