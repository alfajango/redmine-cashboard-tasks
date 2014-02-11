module CashboardTasks
  class ContorllerHookListener < Redmine::Hook::ViewListener
    def controller_issues_new_after_save(context={})
      create_cashboard_task(context)
    end

    def controller_issues_edit_after_save(context={})
      create_cashboard_task(context)
    end

    def create_cashboard_task(context)
      issue = context[:issue]
      params = context[:params]
      @project = issue.project

      unless params[:cashboard_project_id].blank? || (params[:cashboard_project_list_title].blank? && params[:cashboard_project_list_id].blank?)
        if params[:cashboard_project_list_title].present?
          @project_list = Cashboard::ProjectList.create(
            :project_id => params[:cashboard_project_id],
            :title => params[:cashboard_project_list_title]
          )
        end

        project_list_id = @project_list ? @project_list.id : params[:cashboard_project_list_id]

        cashboard_project = @project.cashboard_projects.where(:cashboard_project_id => params[:cashboard_project_id]).first_or_create do |cashboard_project|
          cashboard_project.cashboard_project_name = params[:cashboard_project_name]
        end

        if line_item = Cashboard::LineItem.create(
          :project_id => params[:cashboard_project_id],
          :project_list_id => project_list_id,
          :title => issue.subject,
          :quantity_high => issue.estimated_hours
        )
          CashboardTask.create!(
            :issue_id => issue.id,
            :cashboard_project_id => params[:cashboard_project_id],
            :cashboard_project_list_id => project_list_id,
            :cashboard_line_item_id => line_item.id
          )
        end
      end
    end
  end
end
