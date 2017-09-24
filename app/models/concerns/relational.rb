module Relational
  extend ActiveSupport::Concern

  included do
    def foreign_key_name
      self.class.name.foreign_key.to_sym
    end
  end

  class_methods do
    def belongs_to(*classes)
      classes.each do |class_sym|
        define_belong_relation(class_sym.to_s.classify.constantize)
      end
    end

    def has_many(*classes)
      references = classes.map do |item|
        item.to_s.singularize.classify.constantize
      end

      references.each do |class_reference|
        define_has_many_relation(class_reference)
      end

      define_delete_cascade(references)

      before_delete :delete_cascade
    end

    private

    def define_belong_relation(class_reference)
      define_method(class_reference.name.underscore) do
        reference_key = "@#{class_reference.name.foreign_key}"
        class_reference.find(instance_variable_get(reference_key))
      end
    end

    def define_has_many_relation(class_reference)
      define_method(class_reference.name.tableize) do
        if class_reference.managed_index[foreign_key_name].nil?
          return PaginationDecorator.new([])
        end

        ids = class_reference.managed_index[foreign_key_name][id]
        class_reference.find(ids)
      end
    end

    def define_delete_cascade(class_references)
      define_method(:delete_cascade) do
        class_references.each do |class_reference|
          break if class_reference.managed_index[foreign_key_name].nil?

          ids = class_reference.managed_index[foreign_key_name][id]
          instances = class_reference.find(ids)

          instances.each(&:delete)
          class_reference.managed_index[foreign_key_name].delete(id)
        end
      end
    end
  end
end
