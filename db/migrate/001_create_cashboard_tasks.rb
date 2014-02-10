class CreateCashboardTasks < ActiveRecord::Migration
  def change
    create_table :cashboard_tasks do |t|
      t.integer :issue_id
      t.integer :cashboard_project_id
      t.integer :cashboard_project_list_id
      t.integer :cashboard_line_item_id
    end
  end
end
