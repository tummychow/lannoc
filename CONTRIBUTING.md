# Contributing

Pull requests and issues welcome. Let me explain how things are organized.

### content

The nanoc `content` dir contains the... content. Files here are made into items. The `posts` and `tags` directories should generally not be touched (that's all examples). CSS improvements (`content/css`) are welcome, but I'd rather not change [`poole.css`](content/css/poole.css) or [`lanyon.css`](content/css/lanyon.css) since those are from upstream. `assets` is for binary stuff like images.

The root items of `content` are for various standard pages: the [home page](content/index.html), the [post list](content/post.html) and the [about page](content/about.md). You can add new pages here if they're generally useful for a blog template, but don't add new example pages.

The most important front matter item for Lannoc is the `kind` key, which indicates what layouts the item receives. The `title` key is also omnipresent.

In general, don't add JavaScript. I have nothing against js in general, but for a blog template, I'd prefer to leave the use of js up to the user. Lanyon's sidebar is implemented entirely in CSS so that the theme requires no js. Let's keep it that way.

### layouts

The `layouts` directory is for... layouts. I also use this directory for partial templates and chrome that gets included into other layouts. I might improve the organization of this in the future. Basically, [`default.html`](layouts/default.html) corresponds to Lanyon's [`default.html`](https://github.com/poole/lanyon/blob/master/_layouts/default.html). [`head.html`](layouts/head.html) and [`sidebar.html`](layouts/sidebar.html) correspond to Lanyon [`_include`s](https://github.com/poole/lanyon/tree/master/_includes). [`article.html`](layouts/article.html) and [`fixed.html`](layouts/fixed.html) correspond to Lanyon's [`post.html`](https://github.com/poole/lanyon/blob/master/_layouts/post.html) and [`page.html`](https://github.com/poole/lanyon/blob/master/_layouts/page.html). All the templates were translated from Liquid to ERB because I really can't stand Liquid templates, but I haven't changed much from the original Lanyon otherwise.

Note that, if you're coming from Jekyll, you may be used to nested layouts (where each layout can specify a superlayout in its front matter). nanoc doesn't do that - instead, you can layout the item multiple times. After laying out with the first layout, the item's content is now wrapped in that layout, and you can then lay it out again in another layout which wraps around them both. Take a look at the Rules if you're not clear on how this works.

In addition to all those, I added a few partial layouts which are useful for incorporating into other pages. Particularly important is [`article_list.html`](layouts/article_list.html). This layout is rendered whenever you need a list of articles (see `post.html`). If your new layout or page uses a bulleted list of articles, you should generally render this partial, rather than building the list from scratch. That way, the lists all have the same uniform appearance.

### lib

One of the powerful things about nanoc is that you can inject arbitrary Ruby code into it to extend its capabilities at runtime, via the `lib` directory. My preprocess block is still a bit on the heavy side, but even so, the lib directory is useful for various utility functions. I also pull in the rendering helper (for rendering layouts as partials) and the blogging helper (all-around very useful).

The code here is mostly self-explanatory. Add new code only when templates would become unreasonably bloated by the lack thereof - in other words, when you have a problem to solve, try to implement it with templates or rules, before adding code to `lib`. Of course, code in `lib` can greatly simplify your templates, so it's a balance between the view (layouts), the model (content and rules) and the controller (lib and rules).

If your contribution requires a lot of code, you may want to consider making an entirely new Helper (which is basically a Ruby module) in a separate file, and then including it into `helpers.rb`.

### Rules

The [Rules](Rules) file is the heart of nanoc, that crucial feature that puts it above other static site generators. With this file, you get granular control over how your site is built and where the pages go. You can also introduce new pages programmatically with ease thanks to the preprocess block.

In the preprocess block, we do any mutations that are needed to the `@items` array. (This array is frozen once the preprocess step is finished, and I think its elements get frozen too, so this is your only chance to change it.) Right now, I do a lot of work here, but I'm probably going to clean it up and move it to `lib` in the future. Try not to make this block too verbose.

The compile block is fairly straightforward. The files we care about most are HTML and Markdown, both of which get passed through ERB. Then, Markdown gets rendered (Redcarpet) and syntax-highlighted ([CodeRay](https://github.com/rubychan/coderay)), and then all the layouting happens. At the end, we relativize paths, which is useful when hosting on a subdomain (eg a GitHub Page).

Why CodeRay? Mainly because it's pure Ruby. Ultraviolet takes advantage of TextMate grammars, which is great, but it's no longer maintained. CodeRay seems to be alive (for now). Pygments.rb is backed by the well-established Pygments library, but spawning Python processes is slow and forces you to set up a Python environment in which to install Pygments itself. (Lannoc still supports Pygments.rb though; see the [README](README.md#syntax-highlighting).) In the future, nanoc is going to release support for [Rouge](https://github.com/jneen/rouge), which is also pure Ruby, but directly supports Pygments CSS, and I'm going to switch to that because Pygments CSS is easier to work with.

The routing block is pretty simple, and doesn't require much explanation. This is slated for removal in nanoc4 (routes will be integrated into the compile block), so don't get too familiar with it. Note the special route for 404. We do this specifically to support GitHub Pages.

## To Do

- rakefile for automating common tasks (take a look at [octopress rakefile](https://github.com/imathis/octopress/blob/master/Rakefile) for ideas)
- atom feed logos on paginated indices (/atom.xml) and individual tag pages (/tag/yourtaghere/atom.xml)
- pandoc shell-call helper? (i use pandoc a lot)
- rendered excerpts using `<!-- more -->`
- xml sitemap using the existing helper
- move to [rouge](https://github.com/jneen/rouge) (support is in [master](https://github.com/nanoc/nanoc/commit/2d9a7b9), but has not yet been [released](https://github.com/nanoc/nanoc/compare/3.6.9...master))
