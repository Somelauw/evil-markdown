# evil-markdown-mode #

Supplemental evil-mode key-bindings to Emacs markdown-mode.
This is inspired by https://github.com/Somelauw/evil-org-improved and https://github.com/edwtjo/evil-org-mode but for markdown.

## Some features ##

- Bindings for navigation between heading
- Bindings for promotion / demotion of heading
- markdown-element text objects

## Keybindings ##
  
| key            | explanation               |
|----------------|---------------------------|
| M-ret          | insert heading            |
| TAB            | fold / unfold headings    |
| gh, gj, gk, gl | navigate between elements |
| M-h or >>      | promote a heading         |
| M-l or <<      | demote a heading          |
| M-k            | move subtree up           |
| M-j            | move subtree down         |
| vae            | select an element         |
| dae            | delete an element         |

## Requirements ##

- markdown-mode, http://jblevins.org/projects/markdown-mode/ 
- evil-mode, https://github.com/emacs-evil/evil

## Installation ##

```sh
   mkdir -p ~/.emacs.d/plugins; git clone git://github.com/somelauw/evil-markdown.git ~/.emacs.d/plugins/evil-markdown
```

### init.el ###

```emacs-lisp
     (add-to-list 'load-path "~/.emacs.d/plugins/evil-markdown")
     (require 'evil-markdown)
```
 
## License ##

 Gnu General Public License v3.0, http://www.gnu.markdown/copyleft/gpl.html
