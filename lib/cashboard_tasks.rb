require_dependency 'cashboard_tasks/issue_patch'
require_dependency 'cashboard_tasks/project_patch'
require_dependency 'cashboard_tasks/view_hook_listener'

ActionDispatch::Callbacks.to_prepare do
  # use require_dependency if you plan to utilize development mode
  require_dependency 'cashboard_tasks/helper_patch'
  # now we should include this module in ApplicationHelper module
  unless ApplicationHelper.included_modules.include? CashboardTasks::ApplicationHelperPatch
    ApplicationHelper.send(:include, CashboardTasks::ApplicationHelperPatch)
  end
end

Issue.send(:include, CashboardTasks::IssuePatch)
Project.send(:include, CashboardTasks::ProjectPatch)
