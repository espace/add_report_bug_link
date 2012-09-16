require File.dirname(__FILE__) + '/../test_helper'
# Re-raise errors caught by the controller.
class IssuesController; def rescue_action(e) raise e end; end

class IssuesControllerTest < ActionController::TestCase 
  def test_truth
    assert true
  end
end