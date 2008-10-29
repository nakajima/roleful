module Roleful
  class Role
    attr_reader :name, :permissions, :options
    
    def initialize(klass, name, options={})
      @klass, @name, @options = klass, name, options
      @permissions = []
      define_predicate
    end

    def can(permission, &block)
      permission_name = "can_#{permission}?"
      
      fn = block || proc { true }
      meta_def(permission_name) { |target, *args| handle(target, *args, &fn) }
      
      meta_delegate(permission_name)
      add_permission(permission)
    end
    
    def method_missing(sym, *args)
      method_id = sym.to_s
      match_permission_or_predicate(method_id) ? superuser? : super
    end
    
    private
    
    def handle(target, *args, &block)
      target.instance_exec(*args, &block)
    end
    
    def superuser?
      options[:superuser]
    end
    
    def match_permission_or_predicate(method_id)
      method_id.match(/can_[a-zA-Z_]+\?/) or method_id.match(/(#{@klass::ROLES.keys.join('|')})\?/)
    end
    
    def define_predicate
      meta_def("#{name}?") { true }
      meta_delegate("#{name}?")
      meta_delegate("can?")
    end
    
    def can?(target, permission)
      permissions.include?(permission)
    end
    
    def add_permission(name)
      @permissions << name.to_sym
    end
    
    def meta_delegate(name)
      @klass.delegate name, :to => :role_proxy
    end
  end
end