require 'rubygems'
require 'bundler/setup'

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



require 'stringex_lite'
# Invoke stringex's to_url on the target string.
def u(str)
  str.to_url
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
def feed_item(list, title = @config[:title], identifier = '/feed/')
  Nanoc::Item.new(
    '<%= atom_feed(:articles => @item[:list]) %>',
    {:title => title, :extension => 'atom', :list => list},
    identifier
  )
end



# Returns the given string, up to and not including the first instance of
# "<!-- more -->".
def summary(content)
  content[0, content.index('<!-- more -->') || content.length]
end

# Returns true if the argument has a summary.
def has_summary?(content)
  content.include?('<!-- more -->')
end
