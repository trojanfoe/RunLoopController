
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
	$(foreach exe,$(TARGETS),$(shell ./$(exe)))

clean:
	rm -f $(TARGETS) *.o
	rm -rf *.dSYM

