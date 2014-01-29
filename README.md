RunLoopController
=================

RunLoopController is a simple Objective-C class to help drive the run loop within command line utilities.  It supports OSX 10.x (where 'x' is pretty low I reckon).

It really only provides a simple signalling mechanism, using a Mach Port, to allow a run loop to be interrupted so it can examine conditions for termination.

There are 3 test programs provided, which should illustrate its use:

## testAsyncNetworking ##

This is a single-thread test that uses `NSURLConnection` to asynchronously download a web page.

## testMultiTimers ##

This is a multi-threaded test that uses `NSThread`-subclasses and demonstrates how to wait within the main thread's run loop for the worker threads to finish.

## testDispatch ##

This is a multi-threaded test that uses Grand Central Dispatch to perform work in the background and demonstrates a different method of waiting within the main thread's run loop for the workers to finish.

To Build
========
Install the Xcode Command Line tools (or compiler of choice) and run `make all` or `make test`:

    $ make test

License
=======

RunLoopController is released under the MIT Open Source License. This is a very permissive license but I would ask that any improvements or fixes to the library are contributed back so that others may benefit from our combined efforts:

The MIT License (MIT)

Copyright (c) 2014 Andy Duplain.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.