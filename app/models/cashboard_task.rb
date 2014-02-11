class CashboardTask < ActiveRecord::Base
  unloadable

  belongs_to :issue

  validates :issue_id, :cashboard_project_id, :cashboard_project_list_id, :cashboard_line_item_id, :presence => true
end
