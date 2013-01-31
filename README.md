Desdemona
=========

*Release notes moved here for historical purposes; some links are broken.*

Version 0.4.1
-------------

I've released a new version of [Desdemona](http://code.brautaset.org/Desdemona/), my
Reversi game. From the [release note](http://code.brautaset.org/Desdemona/appcast.xml):

> Fixed a nasty bug in the AI which could lead it to make strange (and terrible) moves
> near the end of the game. Also fixed an error in the search optimisation code that
> caused the AI to perform much weaker than it should be.
>
> Given the latter fix I also took the opportunity to overhaul the difficulty levels.
> There was too little difference between them. The same range of levels from 1-10 is
> available, but they now represent a wider range of ability in the AI.
>
> Difficulty level 1 is about the same as it was before. However, at level 10 it will now
> take about 22 seconds to search for a move, up from about 10 seconds previously.
> (Because of the bugfixes, however, the prior version would have to use about 5 minutes
> or more to perform as well!)

Version 0.3
-----------

I've released a new version of my Reversi game. In addition to numerous behind-the-scenes
changes, user-visible changes in this release are:

* Cleaned up the interface and hid some of the clutter in a preferences pane.
* Added a progress indicator to indicate that things are going on in the background.
* Added a "Check for updates" menu item, which uses the wonderful [Sparkle](http://sparkle.andymatuschak.org/) framework to check for updates. You also have the option to automatically check for new versions on startup.

Desdemona continues to use the wonderful graphics from [Gnome
Iagno](http://live.gnome.org/Iagno). It sorely needs a logo though.

[Download Desdemona 0.3.1](http://code.brautaset.org/files/Desdemona_0.3.1.dmg) (0.25 MB
disk image). [Visit the homepage](http://code.brautaset.org/Desdemona/).

**Update, 7th May:** I just fixed a bug that caused the default values for the preferences
not to be registered. This could cause the AI level and board size to be used
uninitialised, and could lead to crashes. I have uploaded 0.3.1, and fixed the above link
to point to the good version.


Version 0?
----------

I've been playing with Cocoa a bit lately and just uploaded
[Desdemona.dmg](/files/desdemona/Desdemona.dmg). It contains a version of the classic
Reversi (aka Othello) game called [Desdemona](/software/desdemona/). It is written in
Objective-C and the code is available [here](/svn/Desdemona/) (GPL v2 applies).
