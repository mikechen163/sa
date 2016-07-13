class Object
   # 扩展Object类，添加metaclass方法，返回meta-class
   def metaclass; class << self; self; end; end
   def meta_eval &blk; metaclass.instance_eval &blk; end

   # 添加方法到meta-class
   def meta_def name, &blk
     meta_eval { define_method name, &blk }
   end

   # 类里创建实例方法
   def class_def name, &blk
     class_eval { define_method name, &blk }
   end
 end