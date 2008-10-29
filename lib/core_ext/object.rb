class Object
  unless respond_to?(:instance_exec)
    def instance_exec(*arguments, &block)
      block.bind(self)[*arguments]
    end
  end
end