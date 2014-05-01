require 'rubygems'
require 'bundler/setup'

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
      '<%= render \'partials/article_list\', :articles => @item[:list] %>',
      {
        :title => Date.new(year).strftime(@config[:year]),
        :kind => 'fixed', :extension => 'html', :list => a_year
      },
      Date.new(year).strftime('/%Y/')
    )

    months[year].each do |month, a_month|
      ret << Nanoc::Item.new(
        '<%= render \'partials/article_list\', :articles => @item[:list] %>',
        {
          :title => Date.new(year, month).strftime(@config[:monthyear]),
          :kind => 'fixed', :extension => 'html', :list => a_month
        },
        Date.new(year, month).strftime('/%Y/%m/')
      )

      days[year][month].each do |day, a_day|
        ret << Nanoc::Item.new(
          '<%= render \'partials/article_list\', :articles => @item[:list] %>',
          {
            :title => Date.new(year, month, day).strftime(@config[:date]),
            :kind => 'fixed', :extension => 'html', :list => a_day
          },
          Date.new(year, month, day).strftime('/%Y/%m/%d/')
        )
      end
    end
  end

  ret
end
