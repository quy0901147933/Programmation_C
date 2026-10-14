# Makefile — TD Stockage de matrices en C
# Dùng: make test1 | make test2 | make test3 | make demo

CC      = gcc
CFLAGS  = -std=c11 -Wall -Wextra -Wpedantic -g

# -------- Modules communs --------
OBJS_BASE  = matrice.o matrice_alloc.o
OBJS_IO    = matrice_io.o
OBJS_CALC  = matrice_calcul.o

# -------- Cibles de test --------
test1: $(OBJS_BASE) test_ex1.c
	$(CC) $(CFLAGS) -DMAT_TEST_ALLOC test_ex1.c matrice.c matrice_alloc.c -o test_ex1
	./test_ex1

test2: $(OBJS_BASE) $(OBJS_IO) test_ex2.c
	$(CC) $(CFLAGS) -DMAT_TEST_ALLOC test_ex2.c matrice.c matrice_alloc.c matrice_io.c -o test_ex2
	./test_ex2

test3: $(OBJS_BASE) $(OBJS_CALC) test_ex3.c
	$(CC) $(CFLAGS) -DMAT_TEST_ALLOC test_ex3.c matrice.c matrice_alloc.c matrice_calcul.c -o test_ex3
	./test_ex3

# -------- Programme final --------
demo: main.c $(OBJS_BASE) $(OBJS_IO) $(OBJS_CALC)
	$(CC) $(CFLAGS) main.c matrice.c matrice_alloc.c matrice_io.c matrice_calcul.c -o demo_matrices

# -------- Règles de compilation séparée --------
matrice.o: matrice.c matrice.h
	$(CC) $(CFLAGS) -c matrice.c

matrice_alloc.o: matrice_alloc.c matrice_alloc.h matrice.h
	$(CC) $(CFLAGS) -c matrice_alloc.c

matrice_io.o: matrice_io.c matrice_io.h matrice_alloc.h matrice.h
	$(CC) $(CFLAGS) -c matrice_io.c

matrice_calcul.o: matrice_calcul.c matrice_calcul.h matrice_alloc.h matrice.h
	$(CC) $(CFLAGS) -c matrice_calcul.c

# -------- Nettoyage --------
clean:
	rm -f *.o test_ex1 test_ex2 test_ex3 demo_matrices R.txt

.PHONY: test1 test2 test3 demo clean
