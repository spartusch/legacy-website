Legacy Website
==============

This is my personal homepage that was originally and still is hosted at home.arcor.de/partusch. It dates back to the year 2001. More interesting than that is the fact that it uses a custom build system.

Build System
------------

The custom build system I wrote for it produces static XHTML files out of XML files. In general you just write your contents in a custom XML format and then fire up a Perl script (./toXhtml.pl). That script calls an XSLT processor (Xerces) to apply an XSLT style sheet (xhtml10strict.xsl) to the XML files and generates proper XHTML output.

The build system searches the folders xml\_en and xml\_de to find XML files to process. The output is stored in html_en or html\_de. Each XML file results in a matching XHTML file.

Other features of the build system:

* Detects which XML files were changed since the last upload and processes only those files
* Acronyms are detected and "explained" using <abbr>-tags automatically
* Common strings are specified centrally

Important files
---------------

* FindModified.pm - Perl module to find modified files
* findmodified.db - Database written by FindModified.pm
* xhtml10strict.xsl - The XSLT file for transforming the XML format to XHTML
* acronyms - Key-value mappings for acronyms to detect automatically
* common\_de.xml - Common German strings
* common\_en.xml - Common English strings
* toXhtml.pl - Perl script to find and transform XML files
* upload.pl - Perl script to upload new or modified files
