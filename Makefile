# Makefile for raytracer

CC=nvcc

travel: ptravel.o
	$(CC) $< -o $@

test: example.o
	$(CC) $< -o $@

perm: kth-perm.o
	$(CC) $< -o $@

permtest:
	./perm

exec:
	./travel -c 5 -n 1024 -s 1543259701

.PHONY: clean
clean:
	$(RM) *.o