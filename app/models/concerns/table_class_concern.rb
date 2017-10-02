module TableClassConcern
  extend ActiveSupport::Concern

  module ClassMethods
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
      query_dup = query.dup
      index_result = index_where(query_dup) || managed_data.keys

      filter_by_query(index_result, query_dup)
    end

    def index_where(query)
      indexed_query = query.slice(*indexed_fields)
      return nil if indexed_query.size.zero?

      query.except!(*indexed_fields)
      union_indexes(indexed_query)
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

    def fully_refresh_index
      IndexManager.instance[table_name] = {}
      max_shift = managed_data.size / data_size

      max_shift.times do |shift|
        from_mem(managed_data_by_shift(shift)).index_data(shift)
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
      PaginationDecorator.new(ids_to_filter) if filter_query.empty?

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

    def union_indexes(indexed_query)
      first_arg = indexed_query.shift
      unioned = managed_index[first_arg[0]].fetch(first_arg[1], [])

      indexed_query.each do |key, value|
        break if unioned.empty?

        unioned & managed_index[key].fetch(value, [])
      end

      unioned
    end
  end
end
