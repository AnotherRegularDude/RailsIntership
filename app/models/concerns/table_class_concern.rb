module TableClassConcern
  extend ActiveSupport::Concern

  class_methods do
    def create(params)
      if params.instance_of? Array
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
      if find_value.instance_of? Array
        select_from_ids_arr(find_value)
      else
        select_one_element(find_value.to_i)
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

    def index_where(query)
      indexed_query = query.slice(*indexed_fields)
      return nil if indexed_query.size.zero?

      min_key, min_value = min_index(indexed_query)

      query.delete(min_key)
      managed_index[min_key][min_value]
    end

    def all
      data_to_paginate = managed_data.map do |key, value|
        { **value, id: key }
      end
      decorate_with_pagination(data_to_paginate)
    end

    private

    def decorate_with_pagination(list_to_decorate)
      PaginationDecorator.new(list_to_decorate.map { |item| new(item) })
    end

    def select_from_ids_arr(ids_arr)
      selected = ids_arr.map do |id|
        { **managed_data[id], id: id } if managed_data[id].present?
      end

      decorate_with_pagination(selected)
    end

    def select_one_element(id)
      selected = managed_data[id]
      new(**selected, id: id) if selected.present?
    end

    def filter_by_query(ids_to_filter, filter_query)
      selected = ids_to_filter.map do |id|
        select_flag = true
        value = managed_data[id]
        filter_query.each { |k, v| select_flag = false if value[k] != v }

        { **value, id: id } if select_flag
      end

      decorate_with_pagination(selected)
    end

    def min_index(query_on_index)
      query_on_index.min_by do |k, v|
        managed_index[k][v] = [] if managed_index[k][v].nil?
        managed_index[k][v].length
      end
    end
  end
end
