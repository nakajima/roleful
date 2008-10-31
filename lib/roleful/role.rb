module Roleful
  class Role
    attr_reader :name, :permissions, :handlers, :options
    
    def initialize(klass, name, options={})
      @klass, @name, @options = klass, name, options
      @permissions = Set.new
      @handlers = { }
      define_predicates
    end

    def can(permission, &block)
      permission_name = "can_#{permission}?"
      
      handlers[permission] = block || proc { true }
      meta_def(permission_name) { |target, *args| handle(target, permission, *args) }
      
      meta_delegate(permission_name)
      add_permission(permission)
    end
    
    def can?(target, permission, *args)
      superuser? ?
        @klass::PERMISSIONS.include?(permission) : 
        handle(target, permission, *args)
    end
    
    def method_missing(sym, *args)
      method_id = sym.to_s
      match_permission_or_predicate?(method_id) ? superuser? : super
    end
    
    private
    
    def handle(target, permission, *args)
      return false if handlers[permission].nil?
      target.instance_exec(*args, &handlers[permission])
    end
    
    def superuser?
      options[:superuser] || false # returns false, not nil
    end
    
    def permission?(method)
      method.match(/can_[a-zA-Z_]+\?/)
    end
    
    def predicate?(method)
      method.match(/(#{@klass::ROLES.keys.join('|')})\?/)
    end
    
    def match_permission_or_predicate?(method_id)
      permission?(method_id) or predicate?(method_id)
    end
    
    def define_predicates
      meta_def("#{name}?") { true }
      meta_delegate("#{name}?")
      meta_delegate("can?")
    end
    
    def add_permission(permission)
      permission = permission.to_sym
      @permissions.add(permission)
      @klass::PERMISSIONS.merge(@permissions)
    end
    
    def meta_delegate(name)
      @klass.delegate_permission name, :to => :role_proxy
    end
  end
end