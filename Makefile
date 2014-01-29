
CC = clang
MFLAGS = -DLOGGING -DDEBUG=1 -g -fobjc-arc
LDFLAGS = -g
LIBS = -framework Foundation

TARGETS = testAsyncNetworking testMultiTimers
SRCS = $(wildcard *.m)
OBJS = $(SRCS:.m=.o)

%.o: %.m
	$(CC) $(MFLAGS) -c -o $@ $<

all: $(TARGETS)

testAsyncNetworking: testAsyncNetworking.o RunLoopController.o
	$(CC) $(LDFLAGS) -o $@ testAsyncNetworking.o RunLoopController.o $(LIBS)

testMultiTimers: testMultiTimers.o RunLoopController.o
	$(CC) $(LDFLAGS) -o $@ testMultiTimers.o RunLoopController.o $(LIBS)

clean:
	rm -f $(TARGETS) *.o
	rm -rf *.dSYM

