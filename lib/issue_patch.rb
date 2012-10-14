require_dependency 'issue'
module IssuePatch
  def self.included(base)
    base.send(:extend,ClassMethods)
    base.send(:include, InstanceMethods)
  end
  module ClassMethods
    
  end
  module InstanceMethods
    def defaults_from(arg)
      issue = arg.is_a?(Issue) ? arg : Issue.visible.find(arg)
      self.start_date = Date.today
      temp = issue.attributes.dup.except("id", "created_on", "updated_on","status_id","subject","description","tracker_id","estimated_hours","done_ratio","start_date","text_id", "lft", "rgt")
      unless issue.fixed_version.try(:open?)
        temp = temp.dup.except("fixed_version_id")
      end
      self.assign_attributes(temp)
      self.custom_values = issue.custom_values.collect {|v| v.clone}
      self
    end
  end
end