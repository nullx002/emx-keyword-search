# emx-keyword-search

keyword search for emacs based on https://github.com/keyword-search/keyword-search

Browser style keyword search for Emacs based on browse-apropos-url.

See <http://www.emacswiki.org/emacs/BrowseAproposURL>

Installation
------------

Create a new directory called `emx-keyword-search` in your `.emacs.d` directory

Download folder and add emx-keyword-search.el file to that folder

Add this to your `.emacs` or `.emacs.d/init.el` file: `(require 'emx-keyword-search)`

Load emacs, now `M-x byte-compile-file RET` and than path to your `emx-keyword-search.el` file.

`emx-keyword-search` is a fork of `keyword-search` available on [MELPA](http://melpa.org).

Basic Configuration
-------------------

You can set default search engine with the following command.

* <kbd>M-x customize-variable [RET] keyword-search-default [RET]</kbd>

You can append search engines with the following commands.

* <kbd>C-h v keyword-search-alist [RET]</kbd>
* <kbd>M-x customize-variable [RET] keyword-search-alist [RET]</kbd>

Please refer to the comment of `keyword-search.el`.

Usage
-----

1. <kbd>M-x keyword-search [RET]</kbd>
2. Choose search engine. <kbd>[TAB]</kbd> will autocomplete it.
3. Search query will be read from symbol at point, region or string in the minibuffer.

