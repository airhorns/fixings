# frozen_string_literal: true

module Fixings
  class TrestleAdminAuthConstraint
    def matches?(request)
      !!request.session[:trestle_user]
    end
  end
end
