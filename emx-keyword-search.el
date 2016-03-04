;;; emx-keyword-search.el --- browser keyword search from Emacs
;;
;; Minor edits: ~nullx002
;; Authors: hugo and Richard Riley
;; Maintainer: Jens Petersen
;; Provisional maintainer: Akihiro Kuroiwa
;; Created: 29 Jun 2013
;; Keywords: web, search, keyword
;; XX-URL: https://github.com/juhp/keyword-search
;; X-URL: https://github.com/keyword-search/keyword-search
;; Version: 0.2.2

;; forked by ~nullx002 from https://github.com/keyword-search/keyword-search/blob/master/keyword-search.el
;; with some minor edits and search engines added for text browsers like w3m and elinks.
;; renamed to prevent edits from melpa becasue keyword-search.el is there in melpa packages. 

;; This file is not part of GNU Emacs.

;; This code is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or
;; (at your option) any later version.

;; This code is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;; See the GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is based on the code snippets at
;; http://www.emacswiki.org/emacs/BrowseAproposURL
;; (maybe if a complete file had been posted there
;; Author would not have forked this off).

;; It provides 3 functions `emacs-keyword-search', `emx-keyword-search-at-point'
;; and `emx-keyword-search-quick'.
;;
;; `emx-keyword-search': provides completion on keywords and then reads
;; a search term defaulting to the symbol at point.
;;
;; `emx-keyword-search-at-point': reads a keyword with completion and then
;; searchs with the symbol at point.
;;
;; `emx-keyword-search-quick': reads a query in one line if it does not
;; start with a keyword it uses `emx-keyword-search-default'.

;; To use:

;; (load "keyword-search")
;; (define-key mode-specific-map [?b] 'keyword-search)
;; (define-key mode-specific-map [?B] 'keyword-search-quick)

;; Example of a direct search binding:
;;
;; (eval-after-load 'haskell-mode
;;   '(define-key haskell-mode-map (kbd "C-c h")
;;      (lambda ()
;;        (interactive)
;;        (keyword-search "hayoo"))))

;;; Code:

(require 'browse-url)

;;;###autoload
(defcustom emx-keyword-search-alist
  '(
    (ddg . "https://duckduckgo.com/lite/?q=%s")
    (reddit . "https://www.reddit.com/search?q=%s")
    (alc . "http://eow.alc.co.jp/search?q=%s")
    (cookpad-ja . "http://cookpad.com/search/%s")
    (cookpad-us . "https://cookpad.com/us/search/%s")
    (debpkg . "http://packages.debian.org/search?keywords=%s")
    (dict-org . "http://www.dict.org/bin/Dict?Form=Dict2&Database=*&Query=%s")
    (emacswiki . "http://www.emacswiki.org/cgi-bin/wiki?search=%s")
    (foldoc . "http://foldoc.org/%s")
    (github . "https://github.com/search?q=%s")
    (google . "http://www.google.com/search?q=%s")
    (google-books . "https://www.google.com/search?q=%s&tbm=bks")
    (google-finance . "http://www.google.com/finance?q=%s")
    (google-lucky . "http://www.google.com/search?btnI=I%%27m+Feeling+Lucky&q=%s")
    (google-images . "http://images.google.com/images?sa=N&tab=wi&q=%s")
    (google-groups . "http://groups.google.com/groups?q=%s")
    (google-directory . "http://www.google.com/search?&sa=N&cat=gwd/Top&tab=gd&q=%s")
    (google-news . "http://news.google.com/news?sa=N&tab=dn&q=%s")
    (google-translate . "http://translate.google.com/?source=osdd#auto|auto|%s")
    (google-translate-en-ja . "http://translate.google.com/?source=osdd#en|ja|%s")
    (google-translate-ja-en . "http://translate.google.com/?source=osdd#ja|en|%s")
    (hackage . "http://hackage.haskell.org/package/%s")
    (hayoo . "http://holumbus.fh-wedel.de/hayoo/hayoo.html?query=%s")
    (hdiff . "http://hdiff.luite.com/cgit/%s")
    (jisho-org . "http://jisho.org/search/%s")
    (koji . "http://koji.fedoraproject.org/koji/search?match=glob&type=package&terms=%s")
    (slashdot . "http://www.osdn.com/osdnsearch.pl?site=Slashdot&query=%s")
    (ubupkg . "http://packages.ubuntu.com/search?keywords=%s")
    (weblio-en-ja . "http://ejje.weblio.jp/content/%s")
    (wikipedia . "http://en.wikipedia.org/wiki/%s")
    (wikipedia-ja . "http://ja.wikipedia.org/wiki/%s")
    (yahoo . "http://search.yahoo.com/search?p=%s")
    (youtube . "http://www.youtube.com/results?search_query=%s")
    )
  "An alist of pairs (KEYWORD . URL) where KEYWORD is a keyword symbol \
and URL string including '%s' is the search url."
  :type '(alist
	  :key-type (symbol :tag "Name")
	  :value-type (string :tag "URL"))
  :group 'emx-keyword-search
  )

;;;###autoload
(defcustom emx-keyword-search-default 'ddg
  "Default search engine used by `emx-keyword-search' and `emx-keyword-search-quick' \
if none given."
  :type 'symbol
  :group 'emx-keyword-search
  )

(defun emx-keyword-search-get-query ()
  "Return the selected region (if any) or the symbol at point.
This function was copied from `engine-mode.el'."
  (if (use-region-p)
      (replace-regexp-in-string
       "^\s-*\\|\s-*$" ""
       (replace-regexp-in-string
	"[\u3000\s\t\n]+" "\s"
	(buffer-substring (region-beginning) (region-end))))
    (thing-at-point 'symbol)))

;;;###autoload
(defun emx-keyword-search (key query &optional new-window)
  "Read a keyword KEY from `emx-keyword-search-alist' with completion \
and then read a search term QUERY defaulting to the symbol at point.
It then does a websearch of the url associated to KEY using `browse-url'.

When called interactively, if variable `browse-url-new-window-flag' is
non-nil, load the document in a new window, if possible, otherwise use
a random existing one.  A non-nil interactive prefix argument reverses
the effect of `browse-url-new-window-flag'.

When called non-interactively, optional third argument NEW-WINDOW is
used instead of `browse-url-new-window-flag'."
  (interactive
   (let ((key
	  (completing-read
	   (format "Keyword search (default %s): " emx-keyword-search-default)
	   emx-keyword-search-alist nil t nil nil (symbol-name emx-keyword-search-default))))
     (list key
	   (let ((thing (emx-keyword-search-get-query)))
	     (read-string
	      (if thing
		  (format (concat key " (%s): " ) thing)
		(concat key ": " ))
	      nil nil thing)))))
  (let ((url (cdr (assoc (intern-soft key) emx-keyword-search-alist))))
    (browse-url (format url (url-hexify-string query)) new-window)))

;;;###autoload
(defun emx-keyword-search-at-point (key &optional new-window)
  "Read a keyword KEY from `emx-keyword-search-alist' with completion \
and does a websearch of the symbol at point using `browse-url'.

When called interactively, if variable `browse-url-new-window-flag' is
non-nil, load the document in a new window, if possible, otherwise use
a random existing one.  A non-nil interactive prefix argument reverses
the effect of `browse-url-new-window-flag'.

When called non-interactively, optional second argument NEW-WINDOW is
used instead of `browse-url-new-window-flag'."
  (interactive
   (list (completing-read
	  (format "Keyword search at point (default %s): " emx-keyword-search-default)
	  emx-keyword-search-alist nil t nil nil (symbol-name emx-keyword-search-default))))
  (let ((thing (emx-keyword-search-get-query))
	(url (cdr (assoc (intern-soft key) emx-keyword-search-alist))))
    (browse-url (format url (url-hexify-string thing)) new-window)))

;;;###autoload
(defun emx-keyword-search-quick (text)
  "A wrapper of `emx-keyword-search' which read the keyword and \
search query in a single input as argument TEXT from the minibuffer."
  (interactive
   (list (read-string "Keyword search quick: ")))
  (let* ((words (split-string-and-unquote text))
	 (key (car words))
	 (keywordp (assoc (intern-soft key) emx-keyword-search-alist))
	 (keyword (if keywordp key
		    emx-keyword-search-default)))
    (emx-keyword-search (intern-soft keyword)
		    (combine-and-quote-strings (if keywordp (cdr words) words)))))

(provide 'emx-keyword-search)
;;; emx-keyword-search.el ends here
