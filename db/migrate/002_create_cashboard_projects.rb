class CreateCashboardProjects < ActiveRecord::Migration
  def change
    create_table :cashboard_projects do |t|
      t.integer :project_id
      t.integer :cashboard_project_id
      t.string :cashboard_project_name
    end
  end
end
