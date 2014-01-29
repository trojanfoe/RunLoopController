
CC = clang
MFLAGS = -DLOGGING -DDEBUG=1 -g -fobjc-arc
LDFLAGS = -g
LIBS = -framework Foundation

TARGETS = testAsyncNetworking testMultiTimers testDispatch
SRCS = $(wildcard *.m)
OBJS = $(SRCS:.m=.o)

%.o: %.m
	$(CC) $(MFLAGS) -c -o $@ $<

all: $(TARGETS)

testAsyncNetworking: testAsyncNetworking.o RunLoopController.o AsyncDownloader.o
	$(CC) $(LDFLAGS) -o $@ testAsyncNetworking.o RunLoopController.o AsyncDownloader.o $(LIBS)

testMultiTimers: testMultiTimers.o RunLoopController.o
	$(CC) $(LDFLAGS) -o $@ testMultiTimers.o RunLoopController.o $(LIBS)

testDispatch: testDispatch.o RunLoopController.o
	$(CC) $(LDFLAGS) -o $@ testDispatch.o RunLoopController.o $(LIBS)

test: $(TARGETS)
	./testAsyncNetworking -s http://www.google.co.uk http://facebook.com http://stackoverflow.com http://qwerty
	./testAsyncNetworking http://www.google.co.uk http://facebook.com http://stackoverflow.com http://qwerty
	./testMultiTimers
	./testDispatch

clean:
	rm -f $(TARGETS) *.o
	rm -rf *.dSYM

