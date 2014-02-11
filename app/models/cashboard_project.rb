class CashboardProject < ActiveRecord::Base
  unloadable

  belongs_to :project

  validates :project_id, :cashboard_project_id, :cashboard_project_name, :presence => true
end
