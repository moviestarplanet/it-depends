SizeAnalyzer

This Apollo application analyzes the link report output from the MXML compiler to support
examination of the code sizes of packages and classes, and to browse the references
from one class to another.

The "All Classes" window allows browsing of code size summarized by package.  The absolute
code sizes as reported in bytes do not match the actual sizes in the SWF, either compressed
or uncompressed, but the proportional impact of various classes and packages is accurate
and can be extrapolated to the real SWF.

When a class or package is selected on the left, the right hand panel shows three
alternative displays:

	All References		all classes ultimately referred to by any dependency chain
						originating within the selected object, organized by package.
						
	Immediate References	all classes directly referred to by the selected object
	Referring Classes	all classes that directly refer to the selected object

ALT-clicking any class in any window brings up a window that can browse the source for that
class with embedded dependency information.

Classes (not packages) may be dragged and dropped from the "All Classes" window into
another module window, e.g, "Main Module".  This in effect creates a subset of the
main application that can be separately analyzed.  Clicking the "Satisfy References"
button will pull in all classes from the original application that are referred to
by any class in the module.

There is presently no way to create a new module window but that would be easy to add. 