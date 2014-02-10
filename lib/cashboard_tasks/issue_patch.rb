require_dependency 'issue'

module CashboardTasks
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        has_many :cashboard_tasks
      end
    end

    module ClassMethods
      def with_cashboard_tasks
        scoped.where("issues.id IN (SELECT DISTINCT issue_id FROM cashboard_tasks)")
      end

      def without_cashboard_tasks
        scoped.where("issues.id NOT IN (SELECT DISTINCT issue_id FROM cashboard_tasks)")
      end
    end

    module InstanceMethods
      def cashboard_task
        self.cashboard_tasks.last
      end

      def cashboard_task_id
        self.cashboard_tasks.last.pluck(:id)
      end
    end
  end
end
