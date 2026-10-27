# Makefile — TD Stockage de matrices en C
# Usage :
#   make            : biên dịch demo_matrices và ba chương trình test
#   make test2      : biên dịch và chạy test Bài 2 (matrice_io)
#   make test1      : biên dịch và chạy test Bài 1 (matrice_alloc)
#   make test3      : biên dịch và chạy test Bài 3 (matrice_calcul)
#   make test       : chạy toàn bộ 3 bài test
#   make clean      : dọn dẹp các file tạm, file thực thi và file object (.o)

CC      = gcc
CFLAGS  = -std=c11 -Wall -Wextra -Wpedantic -g

# -------------------------------------------------------------
# Cibles principales
# -------------------------------------------------------------
all: demo_matrices test_ex1 test_ex2 test_ex3

# -------------------------------------------------------------
# Programme de démonstration final (Exercice 4)
# -------------------------------------------------------------
demo_matrices: main.o matrice.o matrice_alloc.o matrice_io.o matrice_calcul.o
	$(CC) $(CFLAGS) $^ -o $@

# Biên dịch riêng từng module (.c -> .o)
main.o: main.c matrice.h matrice_alloc.h matrice_io.h matrice_calcul.h
	$(CC) $(CFLAGS) -c main.c

matrice.o: matrice.c matrice.h
	$(CC) $(CFLAGS) -c matrice.c

matrice_alloc.o: matrice_alloc.c matrice_alloc.h matrice.h
	$(CC) $(CFLAGS) -c matrice_alloc.c

matrice_io.o: matrice_io.c matrice_io.h matrice_alloc.h matrice.h
	$(CC) $(CFLAGS) -c matrice_io.c

matrice_calcul.o: matrice_calcul.c matrice_calcul.h matrice_alloc.h matrice.h
	$(CC) $(CFLAGS) -c matrice_calcul.c

# -------------------------------------------------------------
# Exécutables de tests (Exercices 1, 2, 3)
# Cần cờ -DMAT_TEST_ALLOC để kích hoạt bộ test mô phỏng hết bộ nhớ
# -------------------------------------------------------------
test_ex1: test_ex1.c matrice.c matrice_alloc.c
	$(CC) $(CFLAGS) -DMAT_TEST_ALLOC $^ -o $@

test_ex2: test_ex2.c matrice.c matrice_alloc.c matrice_io.c
	$(CC) $(CFLAGS) -DMAT_TEST_ALLOC $^ -o $@

test_ex3: test_ex3.c matrice.c matrice_alloc.c matrice_calcul.c
	$(CC) $(CFLAGS) -DMAT_TEST_ALLOC $^ -o $@

# -------------------------------------------------------------
# Lệnh chạy test nhanh
# -------------------------------------------------------------
test1: test_ex1
	./test_ex1

test2: test_ex2
	./test_ex2

test3: test_ex3
	./test_ex3

test: test1 test2 test3

demo: demo_matrices

# -------------------------------------------------------------
# Nettoyage
# -------------------------------------------------------------
clean:
	rm -f *.o test_ex1 test_ex1.exe test_ex2 test_ex2.exe test_ex3 test_ex3.exe demo_matrices demo_matrices.exe test_ex2_sortie.txt R.txt

.PHONY: all test1 test2 test3 test demo clean
