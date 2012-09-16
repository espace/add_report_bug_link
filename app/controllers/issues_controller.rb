class IssuesController < ApplicationController
  before_filter :get_project,:only=>[:my_new]
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
  
end