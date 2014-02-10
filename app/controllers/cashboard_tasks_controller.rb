class CashboardTasksController < ApplicationController
  unloadable

  before_filter :find_issues, :except => [:get_project_list, :get_projects]
  before_filter :authenticate_cashboard

  def new
    @cashboard_project = @project.cashboard_project
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
    flash[:notice] = "Issues added as tasks to Cashboard."
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

  private

  def authenticate_cashboard
    @cashboard_auth ||= Cashboard::Base.authenticate(ENV['CASHBOARD_SUBDOMAIN'], ENV['CASHBOARD_API_KEY'])
  end
end
