;;; org-datetree.el --- Create date entries in a tree

;; Copyright (C) 2009-2015 Free Software Foundation, Inc.

;; Author: Carsten Dominik <carsten at orgmode dot org>
;; Keywords: outlines, hypermedia, calendar, wp
;; Homepage: http://orgmode.org
;;
;; This file is part of GNU Emacs.
;;
;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:

;; This file contains code to create entries in a tree where the top-level
;; nodes represent years, the level 2 nodes represent the months, and the
;; level 1 entries days.

;;; Code:

(require 'org)

(defvar org-datetree-base-level 1
  "The level at which years should be placed in the date tree.
This is normally one, but if the buffer has an entry with a DATE_TREE
property (any value), the date tree will become a subtree under that entry,
so the base level will be properly adjusted.")

(defcustom org-datetree-add-timestamp nil
  "When non-nil, add a time stamp matching date of entry.
Added time stamp is active unless value is `inactive'."
  :group 'org-capture
  :version "24.3"
  :type '(choice
	  (const :tag "Do not add a time stamp" nil)
	  (const :tag "Add an inactive time stamp" inactive)
	  (const :tag "Add an active time stamp" active)))

;;;###autoload
(defun org-datetree-find-date-create (date &optional keep-restriction)
  "Find or create an entry for DATE.
If KEEP-RESTRICTION is non-nil, do not widen the buffer.
When it is nil, the buffer will be widened to make sure an existing date
tree can be found."
  (org-set-local 'org-datetree-base-level 1)
  (or keep-restriction (widen))
  (save-restriction
    (let ((prop (org-find-property "DATE_TREE")))
      (when prop
	(goto-char prop)
	(org-set-local 'org-datetree-base-level
		       (org-get-valid-level (org-current-level) 1))
	(org-narrow-to-subtree)))
    (goto-char (point-min))
    (let ((year (nth 2 date))
	  (month (car date))
	  (day (nth 1 date)))
      (org-datetree-find-year-create year)
      (org-datetree-find-month-create year month)
      (org-datetree-find-day-create year month day))))

(defun org-datetree-find-year-create (year)
  "Find the YEAR datetree or create it."
  (let ((re "^\\*+[ \t]+\\([12][0-9]\\{3\\}\\)\\(\\s-*?\\([ \t]:[[:alnum:]:_@#%]+:\\)?\\s-*$\\)")
	match)
    (goto-char (point-min))
    (while (and (setq match (re-search-forward re nil t))
		(goto-char (match-beginning 1))
		(< (string-to-number (match-string 1)) year)))
    (cond
     ((not match)
      (goto-char (point-max))
      (or (bolp) (newline))
      (org-datetree-insert-line year))
     ((= (string-to-number (match-string 1)) year)
      (goto-char (point-at-bol)))
     (t
      (beginning-of-line 1)
      (org-datetree-insert-line year)))))

(defun org-datetree-find-month-create (year month)
  "Find the datetree for YEAR and MONTH or create it."
  (org-narrow-to-subtree)
  (let ((re (format "^\\*+[ \t]+%d-\\([01][0-9]\\) \\w+$" year))
	match)
    (goto-char (point-min))
    (while (and (setq match (re-search-forward re nil t))
		(goto-char (match-beginning 1))
		(< (string-to-number (match-string 1)) month)))
    (cond
     ((not match)
      (goto-char (point-max))
      (or (bolp) (newline))
      (org-datetree-insert-line year month))
     ((= (string-to-number (match-string 1)) month)
      (goto-char (point-at-bol)))
     (t
      (beginning-of-line 1)
      (org-datetree-insert-line year month)))))

(defun org-datetree-find-day-create (year month day)
  "Find the datetree for YEAR, MONTH and DAY or create it."
  (org-narrow-to-subtree)
  (let ((re (format "^\\*+[ \t]+%d-%02d-\\([0123][0-9]\\) \\w+$" year month))
	match)
    (goto-char (point-min))
    (while (and (setq match (re-search-forward re nil t))
		(goto-char (match-beginning 1))
		(< (string-to-number (match-string 1)) day)))
    (cond
     ((not match)
      (goto-char (point-max))
      (or (bolp) (newline))
      (org-datetree-insert-line year month day))
     ((= (string-to-number (match-string 1)) day)
      (goto-char (point-at-bol)))
     (t
      (beginning-of-line 1)
      (org-datetree-insert-line year month day)))))

(defun org-datetree-insert-line (year &optional month day)
  (delete-region (save-excursion (skip-chars-backward " \t\n") (point)) (point))
  (insert "\n" (make-string org-datetree-base-level ?*) " \n")
  (backward-char)
  (when month (org-do-demote))
  (when day (org-do-demote))
  (insert (format "%d" year))
  (when month
    (insert
     (format "-%02d" month)
     (if day
	 (format "-%02d %s"
		 day
		 (format-time-string "%A" (encode-time 0 0 0 day month year)))
       (format " %s"
	       (format-time-string "%B" (encode-time 0 0 0 1 month year))))))
  (when (and day org-datetree-add-timestamp)
    (save-excursion
      (insert "\n")
      (org-indent-line)
      (org-insert-time-stamp
       (encode-time 0 0 0 day month year)
       nil
       (eq org-datetree-add-timestamp 'inactive))))
  (beginning-of-line))

(defun org-datetree-file-entry-under (txt date)
  "Insert a node TXT into the date tree under DATE."
  (org-datetree-find-date-create date)
  (let ((level (org-get-valid-level (funcall outline-level) 1)))
    (org-end-of-subtree t t)
    (org-back-over-empty-lines)
    (org-paste-subtree level txt)))

(defun org-datetree-cleanup ()
  "Make sure all entries in the current tree are under the correct date.
It may be useful to restrict the buffer to the applicable portion
before running this command, even though the command tries to be smart."
  (interactive)
  (goto-char (point-min))
  (let ((dre (concat "\\<" org-deadline-string "\\>[ \t]*\\'"))
	(sre (concat "\\<" org-scheduled-string "\\>[ \t]*\\'"))
	dct ts tmp date year month day pos hdl-pos)
    (while (re-search-forward org-ts-regexp nil t)
      (catch 'next
	(setq ts (match-string 0))
	(setq tmp (buffer-substring
		   (max (point-at-bol) (- (match-beginning 0)
					  org-ds-keyword-length))
		   (match-beginning 0)))
	(if (or (string-match "-\\'" tmp)
		(string-match dre tmp)
		(string-match sre tmp))
	    (throw 'next nil))
	(setq dct (decode-time (org-time-string-to-time (match-string 0)))
	      date (list (nth 4 dct) (nth 3 dct) (nth 5 dct))
	      year (nth 2 date)
	      month (car date)
	      day (nth 1 date)
	      pos (point))
	(org-back-to-heading t)
	(setq hdl-pos (point))
	(unless (org-up-heading-safe)
	  ;; No parent, we are not in a date tree
	  (goto-char pos)
	  (throw 'next nil))
	(unless (looking-at "\\*+[ \t]+[0-9]+-[0-1][0-9]-[0-3][0-9]")
	  ;; Parent looks wrong, we are not in a date tree
	  (goto-char pos)
	  (throw 'next nil))
	(when (looking-at (format "\\*+[ \t]+%d-%02d-%02d" year month day))
	  ;; At correct date already, do nothing
	  (progn (goto-char pos) (throw 'next nil)))
	;; OK, we need to refile this entry
	(goto-char hdl-pos)
	(org-cut-subtree)
	(save-excursion
	  (save-restriction
	    (org-datetree-file-entry-under (current-kill 0) date)))))))

(provide 'org-datetree)

;; Local variables:
;; generated-autoload-file: "org-loaddefs.el"
;; End:

;;; org-datetree.el ends here
