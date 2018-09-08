# helm-tracker.el

## Introduction
`helm-tracker` provides a helm interface for gnome tracker. Requires gnome
tracker to be installed.

## Installation
put `helm-tracker.el` where `emacs` can find it `(require 'helm-tracker)` and
bind `helm-tracker` to a key, e.g. `(global-set-key (kbd "C-t") 'helm-tracker)`.

## Tracker
`tracker` has to be installed and configured, see [here](https://wiki.gnome.org/Projects/Tracker/ "Gnome Tracker").

## Usage
The helm buffer simply shows the output of the command `tracker search $command`.
Where `$command` is the search term entered in the helm buffer, for details see
[here](https://wiki.gnome.org/Projects/Tracker/ "Gnome Tracker").