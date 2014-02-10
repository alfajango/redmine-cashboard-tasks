module CashboardTasks
  module ApplicationHelperPatch
    def self.included(base) # :nodoc:
      # sending instance methods to module
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      end
    end

    # Instance methods are here
    module InstanceMethods
      def cashboard_task_links(tasks)
        tasks.map do |task|
          link_to task.cashboard_line_item_id, "https://#{ENV['CASHBOARD_SUBDOMAIN']}.cashboardapp.com/provider/projects/show/#{task.cashboard_project_id}#tasks/#{task.cashboard_line_item_id}", :target => :blank
        end.join(', ').html_safe
      end
    end
  end
end
