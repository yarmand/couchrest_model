module CouchRest
  module Model
    module Associations
      # Special proxy for a collection of items so that adding and removing
      # to the list automatically updates the associated property.
      class CollectionOfProxy < CastedArray

        def initialize(array, property, parent)
          (array ||= []).compact!
          super(array, property, parent)
          casted_by[casted_by_property.to_s] = [] # replace the original array!
          array.compact.each do |obj|
            check_obj(obj)
            casted_by[casted_by_property.to_s] << obj.id
          end
        end

        def << obj
          add_to_collection_with(:<<, obj)
          super(obj)
        end

        def push(obj)
          add_to_collection_with(:push, obj)
          super(obj)
        end

        def unshift(obj)
          add_to_collection_with(:unshift, obj)
          super(obj)
        end

        def []= index, obj
          add_to_collection_with(:[]=, obj, index)
          super(index, obj)
        end

        def pop
          obj = casted_by.send(casted_by_property.options[:proxy_name]).last
          casted_by[casted_by_property.to_s].pop
          obj.set_back_association(nil, casted_by.class.name, casted_by_property.options[:reverse_association])
          casted_by.register_dirty_association(obj)
          super
        end

        def shift
          obj = casted_by.send(casted_by_property.options[:proxy_name]).first
          casted_by[casted_by_property.to_s].shift
          obj.set_back_association(nil, casted_by.class.name, casted_by_property.options[:reverse_association])
          casted_by.register_dirty_association(obj)
          super
        end

        protected

        def check_obj(obj)
          raise "Object cannot be added to #{casted_by.class.to_s}##{casted_by_property.to_s} collection unless saved" if obj.new?
        end

        def add_to_collection_with(method, obj, index=nil)
          check_obj(obj)
          args = [ obj.id ]
          args = args.insert(0, index) if index
          casted_by[casted_by_property.to_s].send(method, *args)
          obj.set_back_association(casted_by, casted_by.class.name, casted_by_property.options[:reverse_association])
          casted_by.register_dirty_association(obj)
        end

        # Override CastedArray instantiation_and_cast method for a simpler
        # version that will not try to cast the model.
        def instantiate_and_cast(obj, change = true)
          couchrest_parent_will_change! if change && use_dirty?
          obj.casted_by = casted_by if obj.respond_to?(:casted_by)
          obj.casted_by_property = casted_by_property if obj.respond_to?(:casted_by_property)
          obj
        end

      end
    end
  end
end
