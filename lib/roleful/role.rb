module Roleful
  class Role
    attr_reader :name, :permissions, :handlers, :options
    
    def initialize(klass, name, options={})
      @klass, @name, @options = klass, name, options
      @permissions = Set.new
      @handlers = { }
      define_predicates
    end

    def can(sym, &block)
      handlers[sym] = block || proc { true }
      
      metaclass.class_eval(<<-END, __FILE__, __LINE__)
        def can_#{sym}?(target, *args)
          handle(target, #{sym.inspect}, *args)
        end
      END

      register_permission(sym)
    end
    
    def can?(target, permission, *args)
      superuser? ?
        @klass::PERMISSIONS.include?(permission) : 
        handle(target, permission, *args)
    end
    
    # Used when the permission in question is granted for the
    # role in question. TODO: Is this really necessary?
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
      method.match(/can_(#{@klass::PERMISSIONS.to_a.join('|')})+\?/)
    end
    
    def predicate?(method)
      method.match(/(#{@klass::ROLES.keys.join('|')})\?/)
    end
    
    def match_permission_or_predicate?(method_id)
      permission?(method_id) or predicate?(method_id)
    end
    
    def define_predicates
      meta_def("#{name}?") { true }
      delegate_predicate("#{name}?")
      delegate_predicate("can?")
    end
    
    def register_permission(permission)
      permission = permission.to_sym
      @permissions.add(permission)
      @klass::PERMISSIONS.merge(@permissions)
      delegate_predicate("can_#{permission}?")
    end
    
    def delegate_predicate(name)
      @klass.delegate_permission name, :to => :role_proxy
    end
  end
end