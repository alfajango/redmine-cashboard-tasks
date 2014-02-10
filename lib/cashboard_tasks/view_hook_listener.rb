module CashboardTasks
  class ViewHookListener < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag 'cashboard_tasks', :plugin => :cashboard_tasks
    end
    render_on :view_issues_context_menu_end, :partial => "cashboard_tasks/context_menu"
    render_on :view_issues_show_details_bottom, :partial => "cashboard_tasks/issue_detail"
  end
end
