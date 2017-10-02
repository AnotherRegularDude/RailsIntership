module DataPlaceOptimizable
  extend ActiveSupport::Concern

  module ClassMethods
    def vacuum_optimize
      @times_to_shift = 0
      @shift = 0

      while data_position_by_shift(@shift).present?
        shift_empty_data(from_mem(managed_data_by_shift(@shift)))
      end
    end

    private

    def shift_empty_data(obj)
      from, to = data_position_by_shift(@shift)

      if obj.nil?
        managed_data[from...to] = ''
        @times_to_shift += 1
      else
        managed_index[:id][obj.id] -= @times_to_shift
        @shift += 1
      end
    end
  end
end
