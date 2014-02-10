class CashboardTasksController < ApplicationController
  unloadable

  before_filter :find_issues, :except => [:get_project_list, :get_projects, :get_line_items, :import_new, :import_create]
  before_filter :find_project, :only => [:import_new, :import_create]
  before_filter :authenticate_cashboard

  def new
    @cashboard_project = @project.cashboard_project
  end

  def import_new
    @cashboard_project = @project.cashboard_project
  end

  def import_create
    # Only used if error causes #import_new to re-render
    @cashboard_project = @project.cashboard_project

    cashboard_line_items = Cashboard::LineItem.list(:query => {:project_list_id => params[:cashboard_project_list_id]})

    cashboard_project = @project.cashboard_projects.where(:cashboard_project_id => params[:cashboard_project_id]).first_or_create do |cashboard_project|
      cashboard_project.cashboard_project_name = params[:cashboard_project_name]
    end

    cashboard_line_items.select { |li| params[:cashboard_line_item_ids].include? li.id.to_s }.each do |li|
      issue = @project.issues.create!(
        :tracker_id => @project.trackers.first.id,
        :author_id => User.current.id,
        :subject => li.title,
        :description => li.description,
        :estimated_hours => li.quantity_high,
        :due_date => li.due_date
      )
      issue.cashboard_tasks.create(
        :cashboard_project_id => params[:cashboard_project_id],
        :cashboard_project_list_id => params[:cashboard_project_list_id],
        :cashboard_line_item_id => li.id
      )
    end

    flash[:notice] = "Issues successfully imported from Cashboard."
    redirect_to project_issues_path(@project)
  end

  def create
    if params[:cashboard_project_id].blank? || (params[:cashboard_project_list_title].blank? && params[:cashboard_project_list_id].blank?)
      flash[:error] = "Please select a Cashboard Project and Task List."
      return render :new
    end

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

    if params[:cashboard_as_combined_line_item]
      grouped = @issues.group_by { |i| !!(i.estimated_hours && i.estimated_hours > 0) }.each do |has_estimated_hours, issues|
        if issues.try(:any?)
          line_item_options = Hash.new.tap do |opt|
            opt[:project_id] = params[:cashboard_project_id]
            opt[:project_list_id] = project_list_id
            opt[:title] = "Tasks #{issues.collect(&:id).join(', ')}"
            opt[:description] = issues.collect { |i| "\n* Task #{i.id}#{" (#{i.estimated_hours}hr)" if has_estimated_hours} - #{i.subject}" }.join('').strip
            opt[:quantity_high] = issues.collect(&:estimated_hours).inject(:+) if has_estimated_hours
          end
          Rails.logger.info "LINE ITEM OPTIONS: "
          Rails.logger.info line_item_options.inspect
          line_item = Cashboard::LineItem.create(line_item_options)
          issues.each do |issue|
            CashboardTask.create!(
              :issue_id => issue.id,
              :cashboard_project_id => params[:cashboard_project_id],
              :cashboard_project_list_id => project_list_id,
              :cashboard_line_item_id => line_item.id
            )
          end
        end
      end
      Rails.logger.info "GROUP: "
      Rails.logger.info grouped.inspect
      if grouped[true].try(:any?) && grouped[false].try(:any?)
        flash[:notice] = "Issues added as combined two tasks to Cashboard, one with aggregate estimate and one with no estimate."
      elsif grouped[true].try(:any?)
        flash[:notice] = "Issues added as combined task with aggregate estimate to Cashboard."
      else
        flash[:notice] = "Issues added as combined task with no estimate to Cashboard."
      end
    else
      @issues.each do |issue|
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
      flash[:notice] = "Issues added as individual tasks to Cashboard."
    end

    redirect_to project_issues_path(@project)
  end

  def get_projects
    projects = Cashboard::Project.list(:query => {:is_archived => false})
    @cashboard_projects = projects.inject Hash.new { |h, k| h[k] = [] }  do |h, p|
      h[p.client_name] << [p.name, p.id]
      h
    end
    render :json => @cashboard_projects
  end

  def get_project_list
    project_id = params[:cashboard_project_id]
    @cashboard_project_list = Cashboard::ProjectList.list(:query => {:project_id => project_id, :is_archived => false})
    render :json => @cashboard_project_list.map { |l| {:id => l.id, :title => l.title} }
  end

  def get_line_items
    project_list_id = params[:cashboard_project_list_id]
    @cashboard_line_items = Cashboard::LineItem.list(:query => {:project_list_id => project_list_id, :type_code => Cashboard::LineItem::TYPE_CODES[:task]})
    render :json => @cashboard_line_items.map { |l| {:id => l.id, :title => l.title} }
  end

  private

  def authenticate_cashboard
    @cashboard_auth ||= Cashboard::Base.authenticate(ENV['CASHBOARD_SUBDOMAIN'], ENV['CASHBOARD_API_KEY'])
  end
end
