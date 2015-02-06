Vala Panel
---

Simple, yet elegant panel.

What's that? Not a fork.  Technically.

This is Vala rewrite of SimplePanel, GTK3 LXPanel fork.

*TODO:*
 * Rewrite core panel in Vala (0.2)
 * Rewrite builtin plugins in Vala using libpeas. (0.2)
 * Write Vala Panel Plugin wrapper for LXTray from simple-panel (it is less buggy) (0.2)
 * Make global menus from Unity Appindicator (rewrite it on Vala but without Ubuntu deps) (0.3)
 * Write Notification Center Applet (0.4)
 * Wayland support, make compositor and complete Wayland support(1.0)
 * Taskbar DBus library for compositor (1.0)
 * Redo ValaPanelIconGrid using GtkFlowBox and such wonders. (poss v2.0)

*Implementation note:*

All elements are written entirely from scratch, using GTK and Vala.
A rewrite took place to lower the barrier of entry for new contributors
and to ease maintainence.

*vala-panel:*

Plugin based panel. Users/developers can provide their own custom applets,
which are fully integrated. They can be moved, added, removed again, and
even broken

*Dependencies:*

*Core:*
 * GLib (>= 2.40.0)
 * GTK3 (>= 3.12.0)
 * libpeas-1.0
 * valac
 
*Plugins:*
 * upower-glib (>= 0.9.20)
 * libwnck (>= 3.4.7)
 * gee-0.8 (not gee-1.0!)




Lastly, always set --prefix=/usr when using autogen.sh, or configure, otherwise you
won't be able to start the desktop on most distros

Author
===
 * Athor <ria.freelander@gmail.com>