# Makefile
all: Schwalb_Lab5

Schwalb_Lab5: Schwalb_Lab5.o
	gcc -o $@ $+

Schwalb_Lab5.o : Schwalb_Lab5.s
	as -o $@ $<

clean:
	rm -vf Schwalb_Lab5 *.o
