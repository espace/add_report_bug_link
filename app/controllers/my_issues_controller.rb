class MyIssuesController < ApplicationController

  before_filter :get_project, :only => [:my_new]
  #before_filter :authorize, :only => [:my_new]
  #before_filter :check_for_default_issue_status, :only => [:my_new]
  before_filter :build_new_issue_from_params, :only => [:my_new]
 
  #helper :watchers
  #include WatchersHelper

   def my_new
    @issue = Issue.new
    @issue.defaults_from(params[:related_to]) if params[:related_to] && params[:do_copy]
    @issue.project = @project
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    if @issue.tracker.nil?
      render_error l(:error_no_tracker_in_project)
      return
    end
    if params[:issue].is_a?(Hash)
      @issue.attributes = params[:issue]
      @issue.watcher_user_ids = params[:issue]['watcher_user_ids'] if User.current.allowed_to?(:add_issue_watchers, @project)
    end
    @issue.author = User.current
    
    default_status = IssueStatus.default
    unless default_status
      render_error l(:error_no_default_issue_status)
      return
    end
    @issue.status = default_status
    @allowed_statuses = ([default_status] + default_status.find_new_statuses_allowed_to(User.current.roles_for_project(@project), @issue.tracker)).uniq
    @priorities = IssuePriority.all
    if request.get? || request.xhr?
      @issue.start_date ||= Date.today
      render :template => 'issues/new'
    else
      requested_status = IssueStatus.find_by_id(params[:issue][:status_id])
      @issue.status = (@allowed_statuses.include? requested_status) ? requested_status : default_status
      call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })
      if @issue.save
        attach_files(@issue, params[:attachments])
        flash[:notice] = l(:notice_successful_create)
        call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
        redirect_to(params[:continue] ? { :action => 'my_new', :project_id=>@issue.project.identifier,:related_to=>params[:related_to],:do_copy=>true } :
                                        { :action => 'show', :id => @issue })
      else
        render :template => 'issues/new'
      end 
    end
  end
  
  def get_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def build_new_issue_from_params
    if params[:id].blank?
      @issue = Issue.new
      if params[:copy_from]
        begin
          @copy_from = Issue.visible.find(params[:copy_from])
          @copy_attachments = params[:copy_attachments].present? || request.get?
          @copy_subtasks = params[:copy_subtasks].present? || request.get?
          @issue.copy_from(@copy_from, :attachments => @copy_attachments, :subtasks => @copy_subtasks)
        rescue ActiveRecord::RecordNotFound
          render_404
          return
        end
      end
      @issue.project = @project
    else
      @issue = @project.issues.visible.find(params[:id])
    end

    @issue.project = @project
    @issue.author = User.current
    # Tracker must be set before custom field values
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    if @issue.tracker.nil?
      render_error l(:error_no_tracker_in_project)
      return false
    end
    @issue.start_date ||= Date.today if Setting.default_issue_start_date_to_creation_date?
    @issue.safe_attributes = params[:issue]

    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current, true)
    @available_watchers = (@issue.project.users.sort + @issue.watcher_users).uniq
  end
end