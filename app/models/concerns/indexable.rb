module Indexable
  extend ActiveSupport::Concern

  included do
    private

    def insert_id_into_index(shift = nil)
      shift ||= self.class.managed_data.size / self.class.data_size - 1

      self.class.managed_index[:id] ||= {}
      self.class.managed_index[:id][id] = shift
    end

    def insert_into_index(field_name)
      self.class.managed_index[field_name] ||= {}
      field_index = self.class.managed_index[field_name]

      field_index[attributes[field_name]] ||= []
      field_index[attributes[field_name]] << id
    end

    def update_at_index(field_name)
      return unless send("#{field_name}_changed?")
      field_index = self.class.managed_index[field_name]
      prev_value, new_value = changes[field_name]

      field_index[new_value] ||= []
      field_index[prev_value].delete(id)
      field_index[new_value] << id
    end

    def delete_at_index(field_name)
      field_index = self.class.managed_index[field_name]
      restore_attributes

      field_index[attributes[field_name]].delete(id)
    end

    def delete_id_at_index
      self.class.managed_index[:id].delete(id)
    end
  end
end
