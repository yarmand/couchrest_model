module CouchRest
  module Model
    module Associations
      extend ActiveSupport::Concern

      # Basic support for relationships between CouchRest::Model::Base

      included do
        after_save :save_dirty_association if respond_to?(:after_save)
      end

      Association = Struct.new(:type, :attribute, :options, :target)

      module ClassMethods

        # Define an association that this object belongs to.
        #
        # An attribute will be created matching the name of the attribute
        # with '_id' on the end, or the foreign key (:foreign_key) provided.
        #
        # Searching for the associated object is performed using a string
        # (:proxy) to be evaluated in the context of the owner. Typically
        # this will be set to the class name (:class_name), or determined
        # automatically if the owner belongs to a proxy object.
        #
        # If the association owner is proxied by another model, than an attempt will
        # be made to automatically determine the correct place to request
        # the documents. Typically, this is a method with the pluralized name of the
        # association inside owner's owner, or proxy.
        #
        # For example, imagine a company acts as a proxy for invoices and clients.
        # If an invoice belongs to a client, the invoice will need to access the
        # list of clients via the proxy. So a request to search for the associated
        # client from an invoice would look like:
        #
        #    self.company.clients
        #
        # If the name of the collection proxy is not the pluralized association name,
        # it can be set with the :proxy_name option.
        #
        # If the owner model define an association back to the belonged model, setting
        # the owner will also set the (:reverse_association) attribute of the owner.
        # After such affectation, saving the object model will also trigger the save of
        # the owner object.
        # (:reverse_association) is optional and should be used only to remove ambiguity,
        # when it can't be calculated from the (:class_name)
        #
        def belongs_to(attrib, *options)
          opts = merge_belongs_to_association_options(attrib, options.first)

          property(opts[:foreign_key], String, opts)

          associations.push(Association.new(:belongs_to, attrib, opts, nil))

          create_association_property_setter(attrib, opts)
          create_belongs_to_getter(attrib, opts)
          create_belongs_to_setter(attrib, opts)
        end

        # Provide access to a collection of objects where the associated
        # property contains a list of the collection item ids.
        #
        # The following:
        #
        #     collection_of :groups
        #
        # creates a pseudo property called "groups" which allows access
        # to a CollectionOfProxy object. Adding, replacing or removing entries in this
        # proxy will cause the matching property array, in this case "group_ids", to
        # be kept in sync.
        #
        # Any manual changes made to the collection ids property (group_ids), unless replaced, will require
        # a reload of the CollectionOfProxy for the two sets of data to be in sync:
        #
        #     group_ids = ['123']
        #     groups == [Group.get('123')]
        #     group_ids << '321'
        #     groups == [Group.get('123')]
        #     groups(true) == [Group.get('123'), Group.get('321')]
        #
        # Of course, saving the parent record will store the collection ids as they are
        # found.
        #
        # The CollectionOfProxy supports the following array functions, anything else will cause
        # a mismatch between the collection objects and collection ids:
        #
        #     groups << obj
        #     groups.push obj
        #     groups.unshift obj
        #     groups[0] = obj
        #     groups.pop == obj
        #     groups.shift == obj
        #
        # Addtional options match those of the the belongs_to method.
        #
        # NOTE: This method is *not* recommended for large collections or collections that change
        # frequently! Use with prudence.
        #
        # If the associated model define an association back to the collection owner model, adding
        # or removing from the collection will also populate the (:reverse_association) attribute
        # of associated model.
        # After such affectation, saving the object model will also trigger the save of
        # the associated object.
        # (:reverse_association) is optional and should be used only to remove ambiguity,
        # when it can't be calculated from the (:class_name)
        #
        def collection_of(attrib, *options)
          opts = merge_belongs_to_association_options(attrib, options.first)
          opts[:foreign_key] = opts[:foreign_key].pluralize
          opts[:readonly] = true

          property(opts[:foreign_key], [String], opts)

          associations.push(Association.new(:collection_of, attrib, opts, nil))

          create_association_property_setter(attrib, opts)
          create_collection_of_getter(attrib, opts)
          create_collection_of_setter(attrib, opts)
        end


        def associations
          @_associations ||= []
        end

        private

        def merge_belongs_to_association_options(attrib, options = nil)
          class_name = options.delete(:class_name) if options.is_a?(Hash)
          class_name ||= attrib
          opts = {
            :foreign_key => attrib.to_s.singularize + '_id',
            :class_name  => class_name.to_s.singularize.camelcase,
            :proxy_name  => attrib.to_s.pluralize,
            :allow_blank => false
          }
          opts.merge!(options) if options.is_a?(Hash)

          # Generate a string for the proxy method call
          # Assumes that the proxy_owner_method from "proxyable" is available.
          if opts[:proxy].to_s.empty?
            opts[:proxy] = if proxy_owner_method
              "self.#{proxy_owner_method}.#{opts[:proxy_name]}"
            else
              opts[:class_name]
            end
          end

          opts
        end

        ### Generic support methods

        def create_association_property_setter(attrib, options)
          # ensure CollectionOfProxy is nil, ready to be reloaded on request
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{options[:foreign_key]}=(value)
              @#{attrib} = nil
              write_attribute("#{options[:foreign_key]}", value)
            end
          EOS
        end

        ### belongs_to support methods

        def create_belongs_to_getter(attrib, options)
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{attrib}
              @#{attrib} ||= #{options[:foreign_key]}.nil? ? nil : #{options[:proxy]}.get(self.#{options[:foreign_key]})
            end
          EOS
        end

        def create_belongs_to_setter(attrib, options)
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{attrib}=(value)
                binding = @#{attrib}
                self.#{options[:foreign_key]} = value.nil? ? nil : value.id
              unless value.nil?
                binding = value
                binding.set_back_association(self, self.class.name, '#{options[:reverse_association]}')
              else
                binding.set_back_association(nil, self.class.name, '#{options[:reverse_association]}')
              end
              register_dirty_association(binding)
              @#{attrib} = value
            end
          EOS
        end

        ### collection_of support methods

        def create_collection_of_getter(attrib, options)
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{attrib}(reload = false)
              return @#{attrib} unless @#{attrib}.nil? or reload
              ary = self.#{options[:foreign_key]}.collect{|i| #{options[:proxy]}.get(i)}
              @#{attrib} = ::CouchRest::Model::Associations::CollectionOfProxy.new(ary, find_property('#{options[:foreign_key]}'), self)
            end
          EOS
        end

        def create_collection_of_setter(attrib, options)
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{attrib}=(value)
              @#{attrib} = ::CouchRest::Model::Associations::CollectionOfProxy.new(value, find_property('#{options[:foreign_key]}'), self)
            end
          EOS
        end

      end

      def set_back_association(value, class_name, reverse_association = nil)
        if reverse_association && !reverse_association.empty?
          prop = self.class.properties.detect { |prop|  prop.name =~ %r{#{reverse_association.to_s.singularize}_ids?} }
          raise "Cannot find reverse association: #{reverse_association}" unless prop
          if attributes[prop.name].class.ancestors.include?(Enumerable)
            instance_eval("#{prop.name}.push('#{value.nil? ? nil : value.id}')")
          else
            send("#{prop.name}=", (value.nil? ? nil : value.id))
          end
        end
      end

      def dirty_associations
        @_dirty_associations ||= []
      end

      def register_dirty_association(obj)
        dirty_associations << obj unless @_dirty_associations.include?(obj)
      end

      def save_dirty_association
        while !dirty_associations.empty? do
          obj = dirty_associations.pop
          obj.save
        end
      end

    end

  end

end
