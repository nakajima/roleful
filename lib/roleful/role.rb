module Roleful
  class Role
    attr_accessor :permissions
    
    def initialize(klass)
      @klass = klass
      @permissions = []
    end
  
    def enhance(&block)
      instance_eval(&block)
    end
  
    def can(permission)
      permissions << permission
      permission_name = "can_#{permission}?"
      meta_def(permission_name) { true }
      meta_delegate(permission_name)
    end
    
    def meta_delegate(name)
      @klass.delegate name, :to => :role_proxy
    end
  end
end