//
// errno.cpp
//
//  Defines errno. This is required because a multithreaded build
// does not know anything about errno as a global variable. Rather
// it uses a function. While this assures correct programs, it does
// mean that it can be difficult to link a single threaded guy
// to a multithreaded app.
//

extern "C" {
	int errno = 0;
}

