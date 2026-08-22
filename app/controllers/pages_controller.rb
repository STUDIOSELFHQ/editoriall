class PagesController < ApplicationController
  allow_unauthenticated_access only: :home
  layout "marketing"

  def home
    redirect_to desks_path if authenticated?
  end
end
