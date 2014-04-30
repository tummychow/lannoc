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
  # see https://github.com/jekyll/jekyll/blob/master/lib/jekyll/url.rb#L92
  # and http://blog.lunatech.com/2009/02/03/what-every-web-developer-must-know-about-url-encoding
  URI.escape(str.gsub(%r{[/=:,;~ ]+}, '-').gsub(%r{[^a-zA-Z\d\-+_.]}, '').downcase)
end



require 'set'
# Generate an array containing all the tags used on the site, in ascending
# order.
def sorted_tags
  tag_set = Set.new
  articles.each do |item|
    tag_set.merge(item[:tags]) if item[:tags]
  end
  tag_set.to_a.sort
end

# Return an array containing only the elements of arr whose tags attribute
# contains the given tag.
def for_tag(arr, tag)
  arr.select { |item| (item[:tags] || []).include?(tag) }
end



# Generate a nanoc item containing an Atom feed for this list of articles.
def feed_item (list, title = @config[:title], identifier = '/feed/')
  Nanoc::Item.new(
    "<%= atom_feed(:articles => @item[:list]) %>",
    {:title => title, :extension => 'atom', :list => list},
    identifier
  )
end



require 'date'
# Generate an array of items. Each item is an index, listing the articles over
# a certain year, month of year, or day of month of year.
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
      {
        :title => Date.new(year).strftime(@config[:year]),
        :kind => 'fixed', :extension => 'html', :list => a_year
      },
      Date.new(year).strftime("/%Y/")
    )

    months[year].each do |month, a_month|
      ret << Nanoc::Item.new(
        "<%= render 'article_list', :articles => @item[:list] %>",
        {
          :title => Date.new(year, month).strftime(@config[:monthyear]),
          :kind => 'fixed', :extension => 'html', :list => a_month
        },
        Date.new(year, month).strftime("/%Y/%m/")
      )

      days[year][month].each do |day, a_day|
        ret << Nanoc::Item.new(
          "<%= render 'article_list', :articles => @item[:list] %>",
          {
            :title => Date.new(year, month, day).strftime(@config[:date]),
            :kind => 'fixed', :extension => 'html', :list => a_day
          },
          Date.new(year, month, day).strftime("/%Y/%m/%d/")
        )
      end
    end
  end

  ret
end
