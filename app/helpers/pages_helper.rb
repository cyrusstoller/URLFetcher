module PagesHelper
  def span_labels(*text)
    res = ""
    text.each do |t|
      res += '<span class="label">' + t + '</span> '
    end
    return (res).html_safe
  end
end
