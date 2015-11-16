## A Humble Disclaimer ##

This project arose out of a hacked-up tool that was created out of sheer necessity as we were trying to make our applications smaller at Allurent.  Therefore, the user interface doesn't reflect my idea of good usability or good design, and I offer my apologies for its many shortcomings.

## Installation ##

If you don't already have the Adobe AIR runtime installed, install it first from http://get.adobe.com/air/.

Then double click the ItDepends.air file you downloaded from this site and run the installer.

## Linkage Projects ##

A _linkage project_ is a collection of input files, search paths and settings used by ItDepends to analyze an application's linkage model.  Elements of a project include:
  * An XML link report produced by the mxmlc compiler for an application
  * A list of directories to search for source code files in the application
  * The main class name for the application
  * A SWFX file produced by the Flex SDK swfx tools from a SWF file (experimental)

## Creating a New Project ##

To create a new project, follow these steps:

1. Click the **Load Link Report...** button on the main window and specify a link report file from mxmlc.  (To create a link report for your application, you can pass the `-link-report=_filename_` option to mxmlc as part of your build process, or specify this option in Flex Builder's Project Properties/Flex Compiler dialog.)

2. In the resulting window, browse your way to the main class of your application and select it, then click the **Set Main Class** button.

3. If you want to view source code, click the **Source Path...** button to add a source directory to be browsed.  You can click this button multiple times to add multiple search paths (yes, this is a lousy user interface!).

## Saving a Project ##

To save the above settings in a single file that can be reloaded easily, click the **Save Project...** button from the Linkage Browser window.

## The Linkage Browser Window ##

After you create your project, you will see a _Linkage Browser_ which displays some overall statistics at the top, and two main panels below.  The left hand panel is the _Package Tree_ and it allows you to browse all the classes and packages in the application, while the right hand panel shows three tabbed detail views that apply to whichever class or package is selected in the left hand tree.

Let's go through the areas of the window one by one.

### Code Statistics ###

  * **Code Size** gives the total size of the code in the linkage browser, with a parenthesized percentage and size relative to the original application as linked by the compiler.  Initially these two numbers will be the same and the proportion will be 100%, but as you explore linkage scenarios by removing classes or creating modules, the number will become smaller.  Note that the number IS NOT CORRECT: it doesn't reflect the actual contribution of the code to the eventual SWF size, because of several factors described below.

  * **References** is the number of external or intrinsic references in the linkage model.

  * **Linked Classes** is the number of classes in the linkage model, followed by a parenthesized class count from the original application.

### Package Tree ###

Each class or package is followed by its percentage of the code size in the application, and the number of bytes in parentheses.  Classes are also shown with a number in square brackets that indicates how many other classes in the linkage model immediately refer to them.

All classes/packages are sorted at each level of the package hierarchy by code size, with the largest shown first.

### Dependency Detail Tabs ###

When a class or package is selected in the left-hand Package Tree, the right hand panel shows three tabbed displays:

**All References** shows all the classes ultimately reached by a chain of dependencies originating with the selected class or package.  If you are thinking of moving the selected item out of the application either by removing it or moving it into a module, these are the classes that might be able to disappear along with it.  Some of them won't be able to disappear, of course, if other classes still depend on them.

**Immediate References** shows the classes on which the selected class or package directly depends: the _outgoing dependencies_.  This is a shorter list than All References.

**Referring Classes** is in many ways the most useful display: it shows a list of all classes which depend on the selected class or package, or the _incoming dependencies_.  If you find a class or package that is large or which has many other dependencies, and you'd like to evict it from your app or move it out into a module, this list tells you which other classes depend directly on it.

## Source Browser ##

Double-clicking a class name in any display brings up a separate _Source Browser_ window that shows all the incoming and outgoing dependencies as hyperlinks that cause the source browser display to show those classes instead.  If you have specified source paths, and the source AS or MXML file could be found, this window will show the source code and will highlight all class name references within the file as hyperlinks of the same kind.

## Working With Deletion Scenarios ##

Once you have explored the landscape of your application, you may well want to explore "what if" scenarios in which you get rid of some classes, and see what your code savings would be.  For instance, you might wonder whether using `flash.net.URLRequest` instead of `mx.rpc.http.HTTPService` would cut down your SWF size.  Selecting the `mx.rpc` package would perhaps show that only a single class in your application uses it.  So you could select the `mx.rpc.http.HTTPService` class in the Linkage Browser and click the **Delete** button.  This will not only remove that class, but remove any other classes that were only linked because HTTPService was there.  As a result, you can find out quickly how much smaller your app will get if you made this change.

You must select a Main Class before you can use the Delete function.

## Working With Module Scenarios ##

Another common scenario to explore is one in which a monolithic application is broken up into modules.  Once you have designated a Main Class, ItDepends allows you to create a separate Linkage Browser for a dynamically loaded module.  To do this, type the module's name into the module name input field at the upper right of the screen, and click the **Create Child Module** button.  A new, empty Linkage Browser will appear for your module.

To explore the linkage picture for your application and its new Module, drag one or more classes and packages from the base application's linkage browser into the module's linkage browser.  Not only will the dragged classes/packages move, but any classes that are no longer needed by anything else in the base application will move too.  The percentages in the Statistics displays in the two browsers show you how your code size breaks up between the modules.

## Known Shortcomings ##

  * You can't move classes back from a module to the base application
  * Multiple-module scenarios aren't very well supported, since there are multiple options for dealing with classes that are common to more than one module
  * Modules that are loaded by other modules aren't supported
  * You can't explore deletion scenarios in a module, only in the base application

## Why the Code Size and Percentages are Inaccurate ##

Firstly, the proportional percentages shown in ItDepends aren't quite correct, because a SWF typically contains a bunch of additional stuff besides what the link report tells ItDepends, like embedded fonts, the Flex preloader, and other assorted non-code-related information.  An average SWF might only be 60-70% code from your Flex application.  So 50% of your code size as reported in ItDepends might turn out to be more like 35% of your SWF size.

Secondly, the numbers in link reports are too large in absolute terms, perhaps because they reflect the size of classes at an intermediate stage of compilation.  Also, SWFs are compiled, and the compression ratio throws things off further.  You might see a code size of 2,000,000 bytes for a SWF that is only 600,000 bytes.

These things are, sadly, normal when working from a link report.  Are link reports the last word?

## Analyzing Dependencies and Code Size with SWFX ##

Maybe link reports aren't the last word.  ItDepends supports size analysis (but not dependency analysis yet) using the output from the SwfxPrinter tool that is part of the Flex 3 SDK.  You can get this output by running a command like this, assuming that your CLASSPATH contains the `lib/asc.jar` and `lib/swfkit.jar` directories from your Flex 3 distribution:

```
java flash.swf.tools.SwfxPrinter -abc -showoffset FILENAME
```

The sizes reported by this tool are more accurate, although they do refer to the uncompressed SWF and so must be adjusted for the zLib compression ratio, typically about 1:0.6 is what I see.