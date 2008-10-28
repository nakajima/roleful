module Roleful
  class Role
    attr_reader :name, :permissions, :options
    
    def initialize(klass, name, options={})
      @klass, @name, @options = klass, name, options
      @permissions = []
      define_predicate
    end
  
    def enhance(&block)
      instance_eval(&block)
    end
  
    def can(permission)
      permission_name = "can_#{permission}?"
      meta_def(permission_name) { true }
      meta_delegate(permission_name)
      add_permission(permission)
    end
    
    def method_missing(sym, *args)
      method_id = sym.to_s
      match_permission_or_predicate(method_id) ? superuser? : super
    end
    
    private
    def superuser?
      options[:superuser]
    end
    
    def match_permission_or_predicate(method_id)
      method_id.match(/can_[a-zA-Z_]+\?/) or method_id.match(/(#{@klass::ROLES.keys.join('|')})\?/)
    end
    
    def define_predicate
      meta_def("#{name}?") { true }
      meta_delegate("#{name}?")
    end
    
    def add_permission(name)
      @permissions << name.to_sym
    end
    
    def meta_delegate(name)
      @klass.delegate name, :to => :role_proxy
    end
  end
end