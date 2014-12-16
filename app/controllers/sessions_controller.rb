class SessionsController < ApplicationController
  layout :false

  def new
    authenticate if params[:shop].present?
  end

  def create
    authenticate
  end
  
  def show
    if response = request.env['omniauth.auth']
      sess = ShopifyAPI::Session.new(params[:shop], response['credentials']['token'])
      session[:shopify] = ShopifySessionRepository.store(sess)
      flash[:notice] = "Logged in"
      redirect_to return_address
    else
      flash[:error] = "Could not log in to Shopify store."
      redirect_to :action => 'new'
    end
  end
  
  def destroy
    session[:shopify] = nil
    flash[:notice] = "Successfully logged out."
    
    redirect_to :action => 'new'
  end
  
  protected

  def authenticate
    #
    # Instead of doing a backend redirect we need to do a javascript redirect
    # here. Open the app/views/commom/iframe_redirect.html.erb file to understand why.
    #
    if shop_name = sanitize_shop_param(params)
      @redirect_url = "/auth/shopify?shop=#{shop_name}"
      render "/common/iframe_redirect"
    else
      redirect_to return_address
    end
  end
  
  # def authenticate
  #   if shop_name = sanitize_shop_param(params)
  #     redirect_to "/auth/shopify?shop=#{shop_name}"
  #   else
  #     redirect_to return_address
  #   end
  # end
  
  def return_address
    session[:return_to] || root_url
  end

  def sanitize_shop_param(params)
    return unless params[:shop].present?
    name = params[:shop].to_s.strip
    name += '.myshopify.com' if !name.include?("myshopify.com") && !name.include?(".")
    name.sub('https://', '').sub('http://', '')
  end
end
  
#   def sanitize_shop_param(params)
#     return unless params[:shop].present?
#     name = params[:shop].to_s.strip
#     name += '.myshopify.com' if !name.include?("myshopify.com") && !name.include?(".")
#     name.sub!(%r|https?://|, '')

#     u = URI("http://#{name}")
#     u.host.ends_with?(".myshopify.com") ? u.host : nil
#   end
# end
