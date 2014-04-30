include Nanoc::Helpers::Rendering
include Nanoc::Helpers::Blogging

require 'redcarpet'
class HTMLPantsCode < Redcarpet::Render::HTML
  include Redcarpet::Render::SmartyPants
  def block_code(code, language)
    # https://gist.github.com/tom--/7329710
    "<pre><code class=\"language-#{language}\">#{h code}</code></pre>"
  end
end

require 'uri'
# Sanitize a single path segment, removing most symbols and whitespace.
def u(str)
  # personally paths with symbols just feel out of place to me, even if they're legal
  # i prefer to sanitize very aggressively
  # plus i could swear webrick can't handle question marks properly which is a pain in development
  # see also https://github.com/jekyll/jekyll/blob/master/lib/jekyll/url.rb#L92
  # and http://blog.lunatech.com/2009/02/03/what-every-web-developer-must-know-about-url-encoding
  URI.escape(str.gsub(%r{[/=:,;~ ]+}, '-').gsub(%r{[^a-zA-Z\d\-+_.]}, '').downcase)
end

require 'set'
def sorted_tags
  tag_set = Set.new
  articles.each do |item|
    tag_set.merge(item[:tags]) if item[:tags]
  end
  tag_set.to_a.sort
end

def for_tag(arr, tag)
  arr.select { |item| (item[:tags] || []).include?(tag) }
end

require 'date'
def articles_period(year = nil, month = nil, day = nil)
  ret = sorted_articles
  ret.select! { |item| attribute_to_time(item[:created_at]).year == year } if year
  ret.select! { |item| attribute_to_time(item[:created_at]).month == month } if month
  ret.select! { |item| attribute_to_time(item[:created_at]).day == day } if day
  ret
end
