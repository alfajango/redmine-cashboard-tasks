require 'cashboard_tasks/issue_patch'
require 'cashboard_tasks/project_patch'
require 'cashboard_tasks/view_hook_listener'

Issue.send(:include, CashboardTasks::IssuePatch)
Project.send(:include, CashboardTasks::ProjectPatch)
