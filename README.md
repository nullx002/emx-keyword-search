# emx-keyword-search

keyword search for emacs based on https://github.com/keyword-search/keyword-search

Browser style keyword search for Emacs based on browse-apropos-url.

See <http://www.emacswiki.org/emacs/BrowseAproposURL>

Installation
------------

Create a new directory called `emx-keyword-search` in your `.emacs.d` directory.

Download zip folder from this page and add emx-keyword-search.el file to that directory you just created.

Add this to your `.emacs` or `.emacs.d/init.el` file: `(require 'emx-keyword-search)`

Load emacs, now `M-x byte-compile-file RET` and than path to your `emx-keyword-search.el` file.

`emx-keyword-search` is a fork of `keyword-search` available on [MELPA](http://melpa.org).

Basic Configuration
-------------------

You can set default search engine with the following command.

* <kbd>M-x customize-variable [RET] emx-keyword-search-default [RET]</kbd>

You can append search engines with the following commands.

* <kbd>C-h v emx-keyword-search-alist [RET]</kbd>
* <kbd>M-x emx-customize-variable [RET] keyword-search-alist [RET]</kbd>

Usage
-----

1. <kbd>M-x keyword-search [RET]</kbd>
2. Choose search engine. <kbd>[TAB]</kbd> will autocomplete it.
3. Search query will be read from symbol at point, region or string in the minibuffer.

Keybindings
-----------

Add following to your `.emacs` or `.emacs.d/init.el` file:

1. (global-set-key (kbd "<f7> s") 'emx-keyword-search)
2. (global-set-key (kbd "<f7> a") 'emx-keyword-search-at-point)
3. (global-set-key (kbd "<f7> d") 'emx-keyword-search-quick)

Make sure that it doesn't conflict with other keybindings you already have.

**!ddg Happy Searching!!**
