class MonitorshipsController < ApplicationController
  before_filter :login_required

  def create
    @monitorship = Monitorship.find_or_initialize_by_user_id_and_topic_id(current_user.id, params[:topic_id])
    @monitorship.update_attribute :active, true
  end
  
  def destroy
    Monitorship.update_all ['active = ?', false], ['user_id = ? and topic_id = ?', current_user.id, params[:topic_id]]
  end
end
