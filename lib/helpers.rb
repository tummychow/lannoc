include Nanoc::Helpers::Rendering
include Nanoc::Helpers::Blogging
include Nanoc::Helpers::HTMLEscape

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

# generates a nanoc item containing an atom feed for this list of articles
def feed_item (list, title = @config[:title], identifier = '/feed/')
  Nanoc::Item.new(
    "<%= atom_feed(:articles => @item[:list]) %>",
    {:title => title, :extension => 'atom', :list => list},
    identifier
  )
end

require 'date'
# returns an array of items, containing indices for the year, month and day
# then you can @items.push(*generate_ymd_indices) to push them into the items list
def generate_ymd_indices
  years = {}
  months = {}
  days = {}

  sorted_articles.each do |item|
    time = attribute_to_time(item[:created_at])

    years[time.year] ||= []
    years[time.year] << item

    months[time.year] ||= {}
    months[time.year][time.month] ||= []
    months[time.year][time.month] << item

    days[time.year] ||= {}
    days[time.year][time.month] ||= {}
    days[time.year][time.month][time.day] ||= []
    days[time.year][time.month][time.day] << item
  end

  ret = []
  years.each do |year, a_year|
    ret << Nanoc::Item.new(
      "<%= render 'article_list', :articles => @item[:list] %>",
      {:title => "#{year}", :kind => 'fixed', :extension => 'html', :list => a_year},
      "/#{year}/"
    )

    months[year].each do |month, a_month|
      ret << Nanoc::Item.new(
        "<%= render 'article_list', :articles => @item[:list] %>",
        {:title => "#{Date::ABBR_MONTHNAMES[month]} #{year}", :kind => 'fixed', :extension => 'html', :list => a_month},
        "/#{year}/#{'%02d' % month}/"
      )

      days[year][month].each do |day, a_day|
        ret << Nanoc::Item.new(
          "<%= render 'article_list', :articles => @item[:list] %>",
          {:title => "#{Date::ABBR_MONTHNAMES[month]} #{day} #{year}", :kind => 'fixed', :extension => 'html', :list => a_day},
          "/#{year}/#{'%02d' % month}/#{'%02d' % day}/"
        )
      end
    end
  end

  ret
end
