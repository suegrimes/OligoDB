class Region < ActiveRecord::Base
  has_many :selectors, :foreign_key => "sl_roi_id"
end
