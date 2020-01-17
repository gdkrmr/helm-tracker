;;; helm-tracker.el --- helm interface for gnome tracker -*- lexical-binding: t; -*-

;; Copyright (C) 2018 by Guido Kraemer

;; Author: Guido Kraemer <guido.kraemer@gmx.de>
;; URL: https://github.com/gdkrmr/helm-tracker
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.4") (helm "2.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; helm-tracker provides a helm interface for gnome tracker. Requires gnome
;; tracker to be installed.

;;; Code:
(require 'helm)

(defgroup helm-tracker nil
  "helm interface for gnome tracker")

(defcustom helm-tracker-max-results 512
  "Maximum number of results `<= 512'"
  :group 'helm-tracker
  :type 'integer)

(defvar helm-tracker--actions
  (helm-make-actions
   "Open file" #'helm-tracker--action-find-file))

(defun helm-tracker--action-find-file (candidate)
  (when (string-prefix-p "  file://" candidate)
    (find-file (substring candidate 9))))


(defun helm-tracker--process-input (input)
  "input is the search term"
  (with-helm-window

    (save-excursion
      ;; 1) Empty lines are removed by helm itself.

      ;; 2) We keep the "Limit reached note" to notify the user that there are
      ;; more results.

      ;; The first line
      (flush-lines "^Results:$")
      ;; The line before "Limit reached" note
      (flush-lines "^  ...$")
      ;; Remove the indentation
      (delete-whitespace-rectangle (point-min) (point-max))

      (goto-char (point-min))
      (forward-line 1)
      (while (re-search-forward "^file:///" nil t)
        (move-end-of-line 1)
        (kill-forward-chars 1)
        (insert ": ")))))


(defun helm-tracker--start-process ()
  (let ((proc (start-process "tracker"
                             nil
                             "tracker"
                             "search"
                             "--disable-color"
                             (concat "--limit=" (number-to-string helm-tracker-max-results))
                             helm-pattern)))
    (set-process-sentinel
     proc
     (lambda (process event)
       (helm-process-deferred-sentinel-hook
        process event (helm-default-directory))
       (when (string= event "finished\n")
         (helm-tracker--process-input helm-input))))
    proc))


(defun helm-tracker--highlight-regexp-in-string (regexp string &optional face)
  "Highlight all occurrences of REGEXP in STRING using FACE.

FACE defaults to the `match' face.  Returns the new fontified
string."
  (with-temp-buffer
    (save-excursion (insert string))
    (while (and (not (eobp))
                (re-search-forward regexp nil t))
      (if (= (match-beginning 0)
             (match-end 0))
          (forward-char)
        (put-text-property
         (match-beginning 0)
         (point)
         'face (or face 'match))))
    (buffer-string)))


(defun helm-tracker--real-to-display (candidate)
  (if (string-prefix-p "  file:///" candidate)
      (propertize candidate 'face 'helm-moccur-buffer)
    candidate))


(defvar helm-source-tracker
  (helm-build-async-source "Gnome Tracker"
    ;; :init 'helm-tracker--do-tracker-set-command
    :candidates-process 'helm-tracker--start-process
    :persistent-action  'helm-tracker--action-find-file
    :action helm-tracker--actions
    ;; :nohighlight t
    :requires-pattern 3
    :candidate-number-limit 512
    :real-to-display 'helm-tracker--real-to-display
    ;; :keymap helm-do-tracker-map
    ;; :follow (and helm-follow-mode-persistent 1)
    ))


;;;###autoload
(defun helm-tracker ()
  (interactive)
  (helm :sources '(helm-source-tracker)
        :buffer "*helm-tracker*"))


(provide 'helm-tracker)
