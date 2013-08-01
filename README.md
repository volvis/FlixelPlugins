FlixelPlugins
========

A hopefully growing collection of plugins and experiments for HaxeFlixel.

## VisualDebug.hx

![drawCross() with position data](VisualDebug.png)

This plugin was created for the sole purpose of drawing debug information on the screen a lot easier. Initially there are only three types of graphics - a point, a cross and text - but the intention is to grow to drawing lines, rectangles and whatnot.

How to use:

    VisualDebug.instance().drawPoint(16,18);