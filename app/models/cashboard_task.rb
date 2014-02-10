class CashboardTask < ActiveRecord::Base
  unloadable

  belongs_to :issue
end
