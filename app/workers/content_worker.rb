require 'net/https'

class ContentWorker
  @queue = :content_worker
  
  def self.perform(content_id)
    @content = Content.find(content_id)

    unless @content.nil?
      fetch_url
      send_callback
    end
  end
  
  def self.fetch_url
    begin
      res = fetch(@content.url)
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        @content.body = res.body
        @content.save
      else
        @content.set_flag_questionable!
      end
    rescue
      @content.set_flag_questionable!
    end
  end
  
  def self.fetch(uri_string, limit = APP_CONFIG["max_redirects"].to_i)
    # You should choose a better exception.
    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    url = URI.parse(uri_string)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    if url.path.blank?
      req = Net::HTTP::Get.new("/")
    else
      req = Net::HTTP::Get.new(url.path)
    end
    req.basic_auth url.user, url.password
    res = http.request(req)
    
    case res
    when Net::HTTPSuccess then
      res
    when Net::HTTPRedirection then
      location = res['location']
      warn "redirected to #{location}"
      @content.add_redirect(location)
      return fetch(location, limit - 1)
    else
      res.value
    end
  end
  
  def self.send_callback
    begin
      # post to the callback url
      unless @content.callback_url.blank?
        uri = URI.parse(@content.callback_url)
        if uri.path.blank?
          req = Net::HTTP::Post.new("/")
        else
          req = Net::HTTP::Post.new(uri.path)
        end
        req['Content-Type'] = "text/plain"
        req.basic_auth uri.user, uri.password
        
        if @content.flag == 0
          if @content.num_redirects == 0
            req.set_form_data({ "content_id" => @content.to_param , "status" => "Content fetched", "url" => @content.url })
          else
            req.set_form_data({ "content_id" => @content.to_param , "status" => "Content fetched", "url" => @content.url,
                                "final_url"  => @content.final_url, "num_redirects" => @content.num_redirects })
          end
        elsif @content.flag == 1
          req.set_form_data({ "content_id" => @content.to_param , "status" => "Content failed to fetch", "url" => @content.url })
        end
                
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        res = http.request(req)

        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          # OK
          @content.callbacks.create!(:status => res.code.to_i)
        else
          # res.error!
          # should possibly retry the post request?
          @content.callbacks.create!(:status => res.code.to_i)
          @content.set_flag_questionable!
        end
      end
    rescue
      # this is to show that the callback url was not legit so potentially questionable
      @content.set_flag_questionable!
    end
  end

end