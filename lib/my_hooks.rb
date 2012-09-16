class MyHooks < Redmine::Hook::ViewListener
  render_on :view_issues_show_details_bottom, :partial => 'view_issues_show_details_bottom'
  render_on :view_issues_form_details_bottom, :partial => 'view_issues_form_details_bottom'
  
  def controller_issues_new_after_save(context={ })
    unless context[:params][:related_to].blank?
      IssueRelation.create!(:issue_from => Issue.find(context[:issue].id), :issue_to => Issue.find(context[:params][:related_to].to_i), :relation_type => 'relates')
    end
  end
end
