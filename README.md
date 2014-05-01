# Lannoc

[Lanyon](https://github.com/poole/lanyon) is a great theme for [Jekyll](http://jekyllrb.com). This is a port of that theme, but to another static site generator, [nanoc](https://github.com/nanoc/nanoc).

Lannoc aims for the same look and feel as the original Lanyon - a pure CSS sidebar that can be toggled on or off, leaving your content front and center. It's primarily intended for blogging, and has first-class support for tags, date-marked posts and an index with next/previous buttons.

This document assumes you have basic familiarity with the concepts of nanoc (items, Rules file, markdown with front matter, etc).

## Usage

All you need out of the box is Ruby and Bundler. I work on Ruby 2.1.1. nanoc is probably capable of working on many other rubies, but no guarantees for the gems Lannoc is using, so I'd stick to a recent MRI Ruby if possible. Clone the repository (or download a zipball/tarball, etc):

```bash
$ git clone git://github.com/tummychow/lannoc.git
$ cd lannoc
$ bundle install
```

Set up the config variables at the bottom of nanoc.yaml, and you're good to go.

## Posts

Lannoc understands two basic types of content: articles and fixed pages (analogous to the post and page layouts from the original Lanyon). Articles are your usual blog posts, with dates and titles and so on. Fixed pages don't have a date, only a title (eg the About page from the original Lanyon).

Articles require three front matter keys (these are mandatory; if you don't include them, then nanoc will crash):

```yaml
---
title: "your title here"
kind: "article"
created_at: 2014-04-12
---

This is a post!
```

You can add more keys if you want. In particular, Lannoc supports a tags key, which is discussed [below](#tags).

Markdown in Lannoc is powered by [Redcarpet](https://github.com/vmg/redcarpet), so it supports tables, strikethrough and fenced code (see [below](#syntax-highlighting)). After being rendered, markdown gets passed through ERB, so it can contain templates. If you don't want spurious newlines in your markdown-ERB, add a trailing hyphen, eg `<%= somevar -%>`.

Article permalinks are constructed Jekyll-style, so the filepath of the article is ignored (only the date and title are relevant to the permalink). Symbols and whitespace are stripped out of the title before the path is constructed. A post whose date is August 21, 2003 and had the title "What's up doc" would have the permalink `/2003/08/21/whats-up-doc/`. Lannoc also provides indexes for the year, month and day. For example, `/2003/08/` would show you all the posts from August of 2003. Dates should be written in the [YAML timestamp format](http://yaml.org/type/timestamp.html) (basically ISO8601), and the format for printed dates is controlled by the `date` key in nanoc.yaml.

## Syntax highlighting

By default, Lannoc uses [CodeRay](https://github.com/rubychan/coderay) for syntax highlighting. If you prefer Pygments, or you want stronger Jekyll compatibility, you can easily switch back to [Pygments.rb](https://github.com/tmm1/pygments.rb). CSS files are included and linked for both highlighters, and I'm pretty confident Lannoc will work with either of them. Just change a single line in the Rules to switch from one to the other.

Due to the interplay of poole.css and coderay.css, it's pretty hard to get table-based line numbering working for CodeRay. (The padding on `pre` elements is all out of whack.) Personally, I think most snippets will be fine without it, and I also think the padding of the original Poole code blocks is nicer without line numbers. I'd gladly accept any CSS improvements if they can make code blocks look good with and without line numbers. In the meantime, if you do want line numbering, apply this patch:

```bash
$ git am line-numbering.patch
```

## Tags

Lannoc provides first-class support for tags in articles, with lots of useful features:

- each tag has an individual page which lists the articles providing that tag
- each tag has its own Atom feed
- each article has a list of tags at the bottom, with links to the individual tag pages
- each individual tag page can be expanded with arbitrary markdown, injected via ERB

To add tags to an article, just include a `tags` array in the front matter.

The individual page for a tag can contain a description written in markdown. The individual tag page is generated whether a description is provided or not, so you can selectively spruce up any tags that deserve more attention, while leaving less important ones undescribed. To indicate that a markdown file is a tag descriptor, use this front matter:

```yaml
---
kind: "tag"
tags: [ "yourtag" ]
---

This is some stuff about my tag.
```

When the `kind` is set to `tag`, this markdown file will be treated as a tag description. No output page will be generated for it. Instead, the markdown content will be substituted directly underneath each tag specified in the `tags` array. In the above example, the page for `yourtag` would feature the description in that file. A description can apply to multiple tags (by specifying each one in the tags array), and a tag can combine multiple descriptions (but the order in which they are included is unpredictable).

## Atom feeds

Lannoc provides Atom feeds for the entire site (`/atom.xml`) and for each tag (`/tag/yourtag/atom.xml`). Every page on the site will have a link to the site-wide Atom feed (see `head.html`), except for the tag pages, which link to their own feeds.

I was going to put in a nice feed icon so you could find the feed more easily, but I can't find any place to put the icon without ruining the clean Lanyon look. If you really want to add the feed icons, I recommend linking [Font Awesome](http://fontawesome.io/get-started/) in `head.html`, and using [their RSS icon](http://fontawesome.io/icon/rss/).

## Pagination

Lannoc provides the same pagination style as Jekyll. All articles will be paginated, and the number of articles per page is set by the `pagination` key in nanoc.yaml. The homepage contains page 1, and then pages are generated by nanoc for each extra page required (/page/2/, /page/3/, etc).

Pagination also has support for summaries of articles. The summary goes from the start of the article's contents, up to the first instance of `<!-- more -->`. (It has to be that exact string - even the whitespace must be the same.) If an article has a summary, then only the summary will be shown on paginated indices. At the end of the summary, there will be a link to read the rest of the article. You can see an example of this in [one of the example articles](content/posts/introducing-lanyon.md).

## Fixed pages

Instead of being an article, a page can also be fixed. This basically means that it doesn't have a date. To set a page as fixed, use the `kind` key, and set it to `fixed`. Fixed pages still need a title, but tags have no meaning for fixed pages.

```yaml
---
title: "a fixed page"
kind: "fixed"
---

page contents here
```

## Sidebar

Lannoc retains Lanyon's sidebar and provides easy sorting of the sidebar contents (which was a royal *pain* with Liquid templates). Anything which specifies the `weight` key in the front matter will be added to the sidebar. Items are sorted by ascending weight. The homepage has a weight of zero. Generally you want that to appear first in the sidebar, but nothing's stopping you from adding negative weights.

Don't add the `weight` key to an item with `kind: "tag"`. nanoc will probably crash, because items with `kind: "tag"` have no path to link to on the sidebar.

## Deployment

Links between pages of the generated site are relative; therefore the site can be deployed directly to GitHub Pages or any similar environment. You'll need to create a Git repository in the output directory, since GitHub doesn't have first-class support for nanoc (ie it doesn't compile nanoc sites on the server - for good reason, since nanoc allows arbitrary code injection). You'll still need to set the `base_url` in nanoc.yaml (required for Atom feeds).

## Drafts

If an item's front matter contains `publish: false` or `draft: true`, then it will not be included in generated content. It won't be referenced by any other generated pages, either (for example, it won't appear on any tag pages). You can override that behavior by specifying `publish_drafts: true` in nanoc.yaml.

## Watch

I usually execute `bundle exec guard` and `bundle exec nanoc view` in the background, to continuously recompile the nanoc site and serve it locally. This is similar to `jekyll serve -w`.

## Uhh... why?

So I've already made a fork of the [original Lanyon](https://github.com/tummychow/lanyon-fork) and a version for [Hugo](https://github.com/tummychow/lanyon-hugo). What on earth would possess me to make a *third* version?

While hacking on the previous two versions of Lanyon that I've made, I eventually found myself fighting the conventions of Jekyll and Hugo. For Jekyll, it was probably the Liquid templates. Non-evaling templates make sense when they're rendered with user-provided data, but they're a real pain in Jekyll, because templates are pretty much the only application logic you have at your command. For Hugo, it was the conventions imposed by the structure (particularly no front matter on nodes).

nanoc has no conventions and is fundamentally more extensible than either of those options, plus it's still maintained (there are a lot of dead static site generators out there). This requires more work up front to set up all your routing and compilation rules, but the control appealed to me. Plus, introducing complex features (eg by-year, by-month, by-day indices) can be done without any modifications to nanoc itself - the extensibility is amazing.

Well, I just needed to port my favorite theme to it... again.

## License

MIT, see [LICENSE.md](LICENSE.md).
