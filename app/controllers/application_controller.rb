class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :xai_configured?

  private
    def xai_configured?
      ENV["XAI_API_KEY"].present?
    end

    def load_desk
      slug = params[:desk_id] || params[:id]
      @desk = Desk.find_by!(slug: slug)
    end

    def require_desk_member
      unless @desk.member?(current_user)
        redirect_to desks_path, alert: "You're not on that desk."
      end
    end
end
