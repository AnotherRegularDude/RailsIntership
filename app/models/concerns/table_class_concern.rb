module TableClassConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def table_name
      name.tableize
    end

    def managed_data
      DbManager.instance[table_name]
    end

    def managed_index
      IndexManager.instance[table_name]
    end

    def data_position(id)
      return if managed_index[:id][id].nil?

      shift = managed_index[:id][id]
      data_begin = shift * data_size
      data_end = data_begin + data_size

      [data_begin, data_end]
    end

    def data_position_by_shift(shift)
      return if shift * data_size >= managed_data.size

      data_begin = shift * data_size
      data_end = data_begin + data_size

      [data_begin, data_end]
    end

    def create(params)
      if params.is_a? Array
        params.each do |instance_params|
          new(instance_params).save
        end
      else
        instance = new(params)
        instance.save

        instance
      end
    end

    def find(find_value)
      if find_value.is_a? Array
        select_from_ids_arr(find_value)
      else
        select_one_element(find_value)
      end
    end

    def find_by_id!(id)
      record = find(id)
      raise ActiveRecord::RecordNotFound if record.nil?

      record
    end

    def select_where(query)
      query_copy = query.dup
      index_result = index_where(query_copy) || managed_data.keys

      filter_by_query(index_result, query_copy)
    end

    # FIXME: Rewrite filter by index.
    def index_where(query)
      indexed_query = query.slice(*indexed_fields)
      return nil if indexed_query.size.zero?

      min_key, min_value = min_index(indexed_query)

      query.delete(min_key)
      managed_index[min_key][min_value]
    end

    def all
      managed_index[:id] ||= {}
      data_to_paginate = managed_index[:id].keys.map do |id|
        from, to = data_position(id)
        from_mem(managed_data[from...to])
      end
      data_to_paginate.select!(&:present?)

      PaginationDecorator.new(data_to_paginate)
    end

    # FIXME: Refactor rubocop warnings.
    def vacuum_optimize
      times_to_shift = 0
      shift = 0

      while data_position_by_shift(shift).present?
        from, to = data_position_by_shift(shift)
        obj = from_mem(managed_data[from...to])

        if obj.nil?
          managed_data[from...to] = ''
          times_to_shift += 1
        else
          managed_index[:id][obj.id] -= times_to_shift
          shift += 1
        end
      end
    end

    def fully_refresh_index
      IndexManager.instance[table_name] = {}
      max_shift = managed_data.size / data_size

      max_shift.times do |shift|
        from, to = data_position_by_shift(shift)
        from_mem(managed_data[from...to]).index_data(shift)
      end
    end

    private

    def select_from_ids_arr(ids_arr)
      selected = ids_arr.map do |id|
        next if data_position(id).nil?
        from, to = data_position(id)

        from_mem(managed_data[from...to])
      end
      selected.select!(&:present?)

      PaginationDecorator.new(selected)
    end

    def select_one_element(id)
      return if data_position(id).nil?

      from, to = data_position(id)
      from_mem(managed_data[from...to])
    end

    def filter_by_query(ids_to_filter, filter_query)
      selected = ids_to_filter.map do |id|
        select_flag = true
        next if data_position(id).nil?

        from, to = data_position(id)
        value = from_mem(managed_data[from...to])

        filter_query.each { |k, v| select_flag = false if value[k] != v }

        value if select_flag
      end

      PaginationDecorator.new(selected)
    end

    def min_index(query_on_index)
      query_on_index.min_by do |k, v|
        managed_index[k][v] ||= []
        managed_index[k][v].length
      end
    end
  end
end
