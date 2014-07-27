Compiling and Running on Linux
	- install the Free Pascal compiler
	- compile the main program
		$ fpc lf.pas
	- compile the data file formatter
		$ fpc lf1bldwd.pas
	- create the data files
		$ ./lf1bldwd
	- run LogFlash!
		$ ./lf

Known Issues
	- The memory management that LogFlash uses is apparently not compatible
	  with newer versions of Free Pascal. I had to comment out all the calls
	  to release(heaporg) to get it to compile. So, presumably, there is now
	  a memory leak.

