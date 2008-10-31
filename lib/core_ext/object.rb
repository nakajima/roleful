class Object
  def try(sym, *args, &block)
    respond_to?(sym) ? send(sym, *args, &block) : nil
  end
  
  def blank?
    to_s == nil.to_s
  end

  unless respond_to?(:instance_exec)
    def instance_exec(*arguments, &block)
      block.bind(self)[*arguments]
    end
  end
end