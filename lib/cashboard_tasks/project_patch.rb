require_dependency 'project'

module CashboardTasks
  module ProjectPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        has_many :cashboard_projects
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def cashboard_project
        self.cashboard_projects.last
      end

      def cashboard_project_id
        self.cashboard_projects.last.pluck(:id)
      end
    end
  end
end
