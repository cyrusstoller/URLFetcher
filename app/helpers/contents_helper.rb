module ContentsHelper
  def show_body(content)
    if content.body.blank?
      if content.flag > 0
        "Fetch failed"
      else
        "Still queued"
      end
    else
      link_to "Show content", content_path(content, :format => "txt")
    end
  end
end
