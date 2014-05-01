# credits: octopress rakefile
# https://github.com/imathis/octopress/blob/master/Rakefile

require 'rubygems'
require 'bundler/setup'
require 'stringex_lite'

content_dir = 'content'
posts_dir = 'posts'

ext = 'md'



# usage: rake article["foo bar baz"]
# or   : rake article foo bar baz
# or   : rake article
desc "Begin a new article in #{content_dir}/#{posts_dir}"
task :article, :title do |t, args|
  if args.title
    title = args.title
  elsif ARGV.length > 1
    # http://itshouldbeuseful.wordpress.com/2011/11/07/passing-parameters-to-a-rake-task/
    title = ARGV[1..-1].join(' ')
    ARGV[1..-1].each do |str|
      task str.to_sym do ; end
    end
  else
    print 'Article title: '
    title = $stdin.gets.chomp
  end

  mkdir_p "#{content_dir}/#{posts_dir}", :verbose => false
  filename = "#{content_dir}/#{posts_dir}/#{title.to_url}.#{ext}"
  abort("File #{filename} already exists, aborting") if File.exist?(filename)

  open(filename, 'w') do |file|
    file.puts '---'
    file.puts "title: \"#{title}\""
    file.puts 'kind: article'
    file.puts "created_at: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}"
    file.puts 'tags: []'
    file.puts '---'
  end
  puts "Created article at \"#{filename}\""
end

# usage: rake compile
# or   : rake
desc 'Compile the site'
task :compile do
  system('bundle exec nanoc compile')
end
task :default => :compile
