module Roleful  
  def self.included(base)
    base.class_eval do
      extend(ClassMethods)
      include(InstanceMethods)
      const_set("ROLES", { })
      const_set("PERMISSIONS", Set.new)
      define_role(:null)
    end
  end
  
  module InstanceMethods
    # Gives an object temporary roles for the duration of the block.
    def with_role(*tmp_roles)
      old_role = method(:role)
      meta_def(:role) { tmp_roles }
      result = yield
      meta_eval { define_method(:role, old_role) }
      result
    end
    
    alias_method :with_roles, :with_role

    private
    
    def role_proxy
      begin
        name = (role || :null).is_a?(Array) ?
          map_roles :
          self.class::ROLES[role.to_sym]
      rescue => e
        warn "#{role.inspect}: #{e}"
        self.class::ROLES[:null]
      end
    end
    
    def map_roles
      role.map { |name| self.class::ROLES[name.to_s.to_sym] }.compact
    end
  end
  
  module ClassMethods
    def role(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      roles = [:all].eql?(args) ? all_roles : args
      roles.each { |name| define_role(name.to_sym, options, &block) }
    end
    
    # Delegates method calls to the object's #role_proxy, accounting for
    # cases when there are multiple roles for the given object.
    def delegate_permission(*methods)
      options = methods.pop
      raise ArgumentError, "Delegation needs a target." unless options.is_a?(Hash) && to = options[:to]

      methods.each do |method|
        module_eval(<<-EOS, "(__DELEGATION__)", 1)
          def #{method}(*args, &block)
            target = Array(send(#{to.inspect}))
            target.any? do |to|
              to.__send__(#{method.inspect}, self, *args, &block)
            end
          end
        EOS
      end
    end
    
    private
    
    def all_roles
      self::ROLES.keys.reject { |name| name.eql?(:null) }
    end
    
    def define_role(name, options={}, &block)
      self::ROLES[name] ||= Roleful::Role.new(self, name, options)
      self::ROLES[name].instance_eval(&block) if block_given?
    end
  end
end
