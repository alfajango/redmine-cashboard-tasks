class CashboardProject < ActiveRecord::Base
  unloadable

  belongs_to :project
end
